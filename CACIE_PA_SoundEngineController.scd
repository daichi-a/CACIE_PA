s = Server.local.boot;
s = Server.local.quit;

(

~initSoundEngine = {
//mapIndex: 0: Harmony, 1: Percussions, 2: Melodies,
//3:External Effects, 4:Internal Effects, 5:Texture Sound

	~valueListForGeneration = List.new;
	~sequenceValueListForGeneration = List.new;
	~sequenceDurationListForGeneration = List.new;
	for(0, 5, {arg mapIndex;
		var listForMapValue = List.new;
		var listForMapSequenceValue = List.new;
		var listForMapSequenceDuration = List.new;
		for(0, 3, {arg indexInMap;
			var listForInstrumentValue = List.new;
			var listForInstrumentSequenceValue = List.new;
			var listForInstrumentSequenceDuration = List.new;
			for(0, 3, {arg positionIndex;
				listForInstrumentValue.add(0.001);
				listForInstrumentSequenceValue.add([\reste, \reste]);
				listForInstrumentSequenceDuration.add([2, 2]);
			});
			listForMapValue.add(listForInstrumentValue);
			listForMapSequenceValue.add(listForInstrumentSequenceValue);
			listForMapSequenceDuration.add(listForInstrumentSequenceDuration);
		});
		~valueListForGeneration.add(listForMapValue);
		~sequenceValueListForGeneration.add(listForMapSequenceValue);
		~sequenceDurationListForGeneration.add(listForMapSequenceDuration);
	});

	~harmonyBasePitchDegree = [0, 0, 0, 0, 0, 0, 0, 0, 0];
	~harmonySecondPitchDegree = [2, 2, 2, 2, 2, 2, 2, 2];
	~harmonyThirdPitchDegree = [4, 4, 4, 4, 4, 4, 4, 4];
	~harmonyForthPitchDegree = [6, 6, 6, 6, 6, 6, 6, 6];


	//Init Texture Source Sounds List

	"After Init Texture Source Sounds List".postln;

	//Init Internal Effect Param List
	~internalEffectParamList = List.new;
	for(0, 3, {arg indexInMap;
		var internalEffectPositionList = List.new;
		for(0, 3, {arg positionIndex;
			var internalEffectEachParamList = List.new;
			for(0, 3, {arg indexOfParam;
				internalEffectEachParamList.add(0.0);
			});
			internalEffectPositionList.add(internalEffectEachParamList);
		});
		~internalEffectParamList.add(internalEffectPositionList);
	});

	//Init Texture Effect Param List
	~textureEffectParamList = List.new;
	for(0, 3, {arg indexInMap;
		var textureEffectPositionList = List.new;
		for(0, 3, {arg positionIndex;
			var textureEffectEachParamList = List.new;
			for(0, 3, {arg indexOfParam;
				textureEffectEachParamList.add(0.0);
			});
			textureEffectPositionList.add(textureEffectEachParamList);
		});
		~textureEffectParamList.add(textureEffectPositionList);
	});

	"After Init Texture Source Sounds List".postln;

	for(0, 3, {arg indexInMap;
		~arpeggioNoteInserter.value(indexInMap);
		~rhythmNoteInserter.value(indexInMap);
		~melodyNoteInserter.value(indexInMap);
		~textureSoundInserter.value(indexInMap);
	});

};

~soundPlayingStatus = false;
~sequenceTempo = 0.5; // Default Value. You should change in each SoundEngine
~currentBar = 0;
~initSoundEngine.value;


///// Harmony Progress
//Harmony Pattern
~harmonyRhythmPatterns = List [[2, 2]];

~harmonyRhythmNoteLists = List.new();
for(0, 3, {arg i;
	~harmonyRhythmNoteLists.add( PatternProxy(Pseq( ~harmonyRhythmPatterns.at(0))));
});

~harmonyBasePitchDegree = List[0, 0, 0, 0, 0, 0, 0, 0, 0];
~harmonySecondPitchDegree = List[2, 2, 2, 2, 2, 2, 2, 2];
~harmonyThirdPitchDegree = List[4, 4, 4, 4, 4, 4, 4, 4];
~harmonyForthPitchDegree = List[6, 6, 6, 6, 6, 6, 6, 6];

~harmonyNoteInserter = { arg indexInMap;
	//For Demo Version
	if((indexInMap == 0),{ //Base Pitch
		for(0, 3, {arg positionIndex;
			~harmonyBasePitchDegree[positionIndex*2] =
				((~valueListForGeneration.at(0).at(indexInMap).at(positionIndex) - 0.001) / (0.99 - 0.001) * (6 - 1) + 1).ceil;
			~harmonyBasePitchDegree[(positionIndex*2)+1] = ~harmonyBasePitchDegree[positionIndex*2];
		});
	});

	if((indexInMap == 0 || indexInMap == 1),{ //Second Pitch
		for(0, 3, {arg positionIndex;
			~harmonySecondPitchDegree[positionIndex*2] = ~harmonyBasePitchDegree[positionIndex*2] +
			((~valueListForGeneration.at(0).at(1).at(positionIndex) - 0.001) / (0.99 - 0.001) * (7 - 1) + 1).ceil;
			~harmonySecondPitchDegree[(positionIndex*2)+1] = ~harmonySecondPitchDegree[positionIndex*2];
		});
	});

	if((indexInMap == 0 || indexInMap == 2), { //Thried Pitch
		for(0, 3, {arg positionIndex;
			~harmonyThirdPitchDegree[positionIndex*2] = ~harmonyBasePitchDegree[positionIndex*2] +
			((~valueListForGeneration.at(0).at(2).at(positionIndex) - 0.001) / (0.99 - 0.001) * (14 - 8) + 8).ceil;
			~harmonyThirdPitchDegree[(positionIndex*2)+1] = ~harmonyThirdPitchDegree[positionIndex*2];
		});
	});

	if((indexInMap == 0 || indexInMap == 3), { //Forth Pitch
		for(0, 3, {arg positionIndex;
			~harmonyForthPitchDegree[positionIndex*2] = ~harmonyBasePitchDegree[positionIndex*2] +
			((~valueListForGeneration.at(0).at(3).at(positionIndex) - 0.001) / (0.99 - 0.001) * (14 - 8) + 8).ceil;
			~harmonyForthPitchDegree[(positionIndex*2)+1] = ~harmonyForthPitchDegree[positionIndex*2];
		});
	});
};

~sendHarmonyInfo = {
	for(0, 3, {arg positionIndex;
		var position = positionIndex * 2;
		~scoreAddr.sendBundle(0.0, ["/CACIE_PA/GUI/harmonyInformation",
			positionIndex,
			~harmonyBasePitchDegree.at(position),
			~harmonySecondPitchDegree.at(position),
			~harmonyThirdPitchDegree.at(position),
			~harmonyForthPitchDegree.at(position)]);

		[~harmonyBasePitchDegree.at(position), ~harmonySecondPitchDegree.at(position),
			~harmonyThirdPitchDegree.at(position), ~harmonyForthPitchDegree.at(position)].postln;

	});
};

~sendScaleInfo = {arg scaleNumber;
	~scoreAddr.sendMsg("/CACIE_PA/GUI/changeScale", scaleNumber);
};

OSCresponder(nil, '/cpp', {arg time, responder, message;
	//message[3].post;"-".post;message[4].postln;
	~currentBar = message[3];
	~guiAddr.sendMsg("/CACIE_PA/GUI/currentPlayingPosition", message[3]);
	~scoreAddr.sendMsg("/CACIE_PA/GUI/currentPlayingPosition", message[3]);
}).add;

SynthDef(\positionSender, {arg cb=0, prm=0;
	//SendReply.kr(Impulse.kr(0), '/cpp', [cb, prm] );
	SendReply.kr(EnvGen.kr(Env.perc, doneAction:2), '/cpp', [cb, prm]);
}).store;


~oscSetValues.remove;
~oscSetValues = OSCresponderNode(nil, '/CACIE_PA/SoundEngine/setValues', {arg t, r, msg;
	var mapIndex = msg[1];
	var indexInMap = msg[2];
	var positionIndex = msg[3];
	var kindOfArg = msg[4]; // value:0, sequence:1,
	var kindOfList; // degree sequence: 0, duration sequence: 1
	var lengthOfList;
	var newList;
	case
		{kindOfArg == 0}
		{	"This is value".post; msg.postln;
			~valueListForGeneration.at(mapIndex).at(indexInMap).put(positionIndex, msg[5]);}
		{kindOfArg == 1}
		{
			//"This is sequence".post; msg.postln;
			kindOfList = msg[5];
			lengthOfList = msg[6];
			newList = List.new;
			for(0, (lengthOfList-1), {arg i; newList.add(msg[7+i])};);
			//newList.postln;
			if((kindOfList === 0),
				{~sequenceValueListForGeneration.at(mapIndex).at(indexInMap).put(positionIndex, newList);},
				{~sequenceDurationListForGeneration.at(mapIndex).at(indexInMap).put(positionIndex, newList);}
			);
		};

}).add;


~oscMakeSequences.remove;
~oscMakeSequences = OSCresponderNode(nil, '/CACIE_PA/SoundEngine/makeSequences', {arg t, r, msg;
	var mapIndex = msg[1];
	var indexInMap = msg[2];
	"~oscMakeSequences:".post; " mapIndex:".post; mapIndex.postln;

	switch(mapIndex,
		0, {~harmonyNoteInserter.value(indexInMap);
			~arpeggioNoteInserter.value(indexInMap);
			~bassNoteInserter.value(indexInMap);
			~sendHarmonyInfo.value;
			~sendScaleInfo.value;},
		1, {~rhythmNoteInserter.value(indexInMap);},
		2, {~melodyNoteInserter.value(indexInMap);},
		3, {~externalEffectsInserter.value(indexInMap);},
		4, {~internalEffectsInserter.value(indexInMap);},
		5, {~textureSoundInserter.value(indexInMap);}
	);

}).add;

~oscSoundEngineInit.remove;
~oscSoundEngineInit = OSCresponderNode(nil, '/CACIE_PA/SoundEngine/initSoundEngine', {arg t, r, msg;
	"/initSoundEngine called".postln;
	~initSoundEngine.value;
}).add;

~oscPlaySound.remove;
~oscPlaySound = OSCresponderNode(nil, '/CACIE_PA/SoundEngine/playSound', {arg t, r, msg;
	"/playSound called".postln;
	if(~soundPlayingStatus,
		{~stopSound.value; ~soundPlayingStatus = false; },
		{~initSoundEngine.value; "After initSoundEngine".postln; ~playSound.value; ~soundPlayingStatus = true;}
	);
}).add;

~oscScaleMode.remove;
~oscScaleMode = OSCresponderNode(nil, '/CACIE_PA/SoundEngine/changeScale', {arg t, r, msg;
	"/changeScale called".postln;
	if((msg[1] == 0), {~pieceScale = Scale.major;},{
		if((msg[1] == 1), {~pieceScale = Scale.harmonicMinor;},{
			if((msg[1] == 2), {~pieceScale = Scale.whole;});});});
	~sendScaleInfo.value(msg[1]);
}).add;

~oscTempo.remove;
~oscTempo = OSCresponderNode(nil, '/CACIE_PA/SoundEngine/changeTempo', {arg t, r, msg;
	"/changeTempo called:".post; msg[1].postln;
	~sequenceTempo = msg[1];
}).add;

~playSound = {
//\V\[\P\\\X\p\^\[\\
//\ʐ^2\\\\1\̃p\^\[\\(1\\\ߕ\)\𐶐\\\\C\\\̃p\^\[\\\\4\q\\\\\ʐ^8\\\\4\\\߂\\\\\\\\\\D
//\\\Y\\\p\[\g\\4\̓\\͂\\\\̂܂܊y\\\ɂȂ\\D
"playSound".postln;

// Texture Base Sound Sequences ///////////////////////////////////////////////////

~textureBaseSound1Pbind = Pbind( //for textureBaseSound1
		\instrument, \textureBaseSound1,
		\scale, Pfunc({~pieceScale}),
		\degree, Pseq([~textureSourceSoundNoteDegreeList.at(0).at(0),
			~textureSourceSoundNoteDegreeList.at(0).at(1),
			~textureSourceSoundNoteDegreeList.at(0).at(2),
			~textureSourceSoundNoteDegreeList.at(0).at(3)], inf),
		\dur, Pseq([~textureSourceSoundNoteDurList.at(0).at(0),
			~textureSourceSoundNoteDurList.at(0).at(1),
			~textureSourceSoundNoteDurList.at(0).at(2),
			~textureSourceSoundNoteDurList.at(0).at(3)], inf) * Pfunc({~sequenceTempo}),
		\amp, Pseq([~textureSourceSoundNoteAmpList.at(0).at(0),
			~textureSourceSoundNoteAmpList.at(0).at(1),
			~textureSourceSoundNoteAmpList.at(0).at(2),
			~textureSourceSoundNoteAmpList.at(0).at(3)], inf),
		\octave, 0
);

~textureBaseSound2Pbind = Pbind( //for textureBaseSound2
		\instrument, \textureBaseSound2,
		\scale, Pfunc({~pieceScale}),
		\degree, Pseq([~textureSourceSoundNoteDegreeList.at(1).at(0),
			~textureSourceSoundNoteDegreeList.at(1).at(1),
			~textureSourceSoundNoteDegreeList.at(1).at(2),
			~textureSourceSoundNoteDegreeList.at(1).at(3)], inf),
		\dur, Pseq([~textureSourceSoundNoteDurList.at(1).at(0),
			~textureSourceSoundNoteDurList.at(1).at(1),
			~textureSourceSoundNoteDurList.at(1).at(2),
			~textureSourceSoundNoteDurList.at(1).at(3)], inf) * Pfunc({~sequenceTempo}),
		\amp, Pseq([~textureSourceSoundNoteAmpList.at(1).at(0),
			~textureSourceSoundNoteAmpList.at(1).at(1),
			~textureSourceSoundNoteAmpList.at(1).at(2),
			~textureSourceSoundNoteAmpList.at(1).at(3)], inf),
		\octave, 4
);

~textureBaseSound3Pbind = Pbind( //for textureBaseSound3
		\instrument, \textureBaseSound3,
		\scale, Pfunc({~pieceScale}),
		\degree, Pseq([~textureSourceSoundNoteDegreeList.at(2).at(0),
			~textureSourceSoundNoteDegreeList.at(2).at(1),
			~textureSourceSoundNoteDegreeList.at(2).at(2),
			~textureSourceSoundNoteDegreeList.at(2).at(3)], inf),
		\dur, Pseq([~textureSourceSoundNoteDurList.at(2).at(0),
			~textureSourceSoundNoteDurList.at(2).at(1),
			~textureSourceSoundNoteDurList.at(2).at(2),
			~textureSourceSoundNoteDurList.at(2).at(3)], inf) * Pfunc({~sequenceTempo}),
		\amp, Pseq([~textureSourceSoundNoteAmpList.at(2).at(0),
			~textureSourceSoundNoteAmpList.at(2).at(1),
			~textureSourceSoundNoteAmpList.at(2).at(2),
			~textureSourceSoundNoteAmpList.at(2).at(3)], inf),
		\octave, 3
);

~textureBaseSound4Pbind = Pbind( //for textureBaseSound4
		\instrument, \textureBaseSound4,
		\scale, Pfunc({~pieceScale}),
		\degree, Pseq([~textureSourceSoundNoteDegreeList.at(3).at(0),
			~textureSourceSoundNoteDegreeList.at(3).at(1),
			~textureSourceSoundNoteDegreeList.at(3).at(2),
			~textureSourceSoundNoteDegreeList.at(3).at(3)], inf),
		\dur, Pseq([~textureSourceSoundNoteDurList.at(3).at(0),
			~textureSourceSoundNoteDurList.at(3).at(1),
			~textureSourceSoundNoteDurList.at(3).at(2),
			~textureSourceSoundNoteDurList.at(3).at(3)], inf) * Pfunc({~sequenceTempo}),
		\amp, Pseq([~textureSourceSoundNoteAmpList.at(3).at(0),
			~textureSourceSoundNoteAmpList.at(3).at(1),
			~textureSourceSoundNoteAmpList.at(3).at(2),
			~textureSourceSoundNoteAmpList.at(3).at(3)], inf),
		\octave, 6
);

// Sequences ///////////////////////////////////////////////////////////////////

x = Ppar([
	Pbind( //Percussion0 //Snare
		\instrument, \percussion_tone0,
		\scale, Pfunc({~pieceScale}),
		[\freq, \dur, \amp],
		Pseq([ ~rhythmNoteLists.at(0).at(0),  ~rhythmNoteLists.at(0).at(1),
				~rhythmNoteLists.at(0).at(2), ~rhythmNoteLists.at(0).at(3) ], inf)
				* Ptuple([1, Pfunc({~sequenceTempo})])
	),

	Pbind( //Percussion1 //Normal Kick
		\instrument, \percussion_tone1,
		\scale, Pfunc({~pieceScale}),
		[\freq, \dur, \amp],
		Pseq([~rhythmNoteLists.at(1).at(0), ~rhythmNoteLists.at(1).at(1),
				~rhythmNoteLists.at(1).at(2), ~rhythmNoteLists.at(1).at(3) ], inf)
				*Ptuple([1, Pfunc({~sequenceTempo})]),
		\decay, Prand([0.1, 0.05, 0.5], inf)
	),

	Pbind( //Percussion2 //Electro Kick
		\instrument, \percussion_tone2,
		\scale, Pfunc({~pieceScale}),
		[\octave, \degree, \dur, \amp],
		Pseq([~rhythmNoteLists.at(2).at(0), ~rhythmNoteLists.at(2).at(1),
				~rhythmNoteLists.at(2).at(2), ~rhythmNoteLists.at(2).at(3) ], inf)
				*Ptuple([1, Pfunc({~sequenceTempo})])
	),


	Pbind( //Percussion3 //hat-2
		\instrument, \percussion_tone3,
		\scale, Pfunc({~pieceScale}),
		[\freq, \dur, \amp],
				Pseq([~rhythmNoteLists.at(3).at(0), ~rhythmNoteLists.at(3).at(1),
				~rhythmNoteLists.at(3).at(2), ~rhythmNoteLists.at(3).at(3) ], inf)
				*Ptuple([1, Pfunc({~sequenceTempo})])
	),


	Pbind( //Base Note of Harmony
		\instrument, \harmony_tone,
		\scale, Pfunc({~pieceScale}),
		\degree, Pseq(~harmonyBasePitchDegree, inf),
		\dur, Pseq([~harmonyRhythmNoteLists.at(0), ~harmonyRhythmNoteLists.at(1),
		~harmonyRhythmNoteLists.at(2), ~harmonyRhythmNoteLists.at(3) ], inf)
		* Pfunc({~sequenceTempo}),
		//\dur, 2 * ~sequenceTempo,
		\octave, 6,
		\amp, 0.1
	),

	Pbind( //Second Note of Harmony
		\instrument, \harmony_tone,
		\scale, Pfunc({~pieceScale}),
		\degree, Pseq(~harmonySecondPitchDegree, inf),
		\dur, Pseq([~harmonyRhythmNoteLists.at(0), ~harmonyRhythmNoteLists.at(1),
		~harmonyRhythmNoteLists.at(2), ~harmonyRhythmNoteLists.at(3) ], inf)
		* Pfunc({~sequenceTempo}),
		//\dur, 2 * ~sequenceTempo,
		\octave, 6,
		\amp, 0.1
	),

	Pbind( //Third Note of Harmony
		\instrument, \harmony_tone,
		\scale, Pfunc({~pieceScale}),
		\degree, Pseq(~harmonyThirdPitchDegree, inf),
		\dur, Pseq([~harmonyRhythmNoteLists.at(0), ~harmonyRhythmNoteLists.at(1),
		~harmonyRhythmNoteLists.at(2), ~harmonyRhythmNoteLists.at(3) ], inf)
		* Pfunc({~sequenceTempo}),
		//\dur, 2 * ~sequenceTempo,
		\octave, 6,
		\amp, 0.1
	),

	Pbind( //Forth Note of Harmony
		\instrument, \harmony_tone,
		\scale, Pfunc({~pieceScale}),
		\degree, Pseq(~harmonyForthPitchDegree, inf),
		\dur, Pseq([~harmonyRhythmNoteLists.at(0), ~harmonyRhythmNoteLists.at(1),
		~harmonyRhythmNoteLists.at(2), ~harmonyRhythmNoteLists.at(3) ], inf)
		* Pfunc({~sequenceTempo}),
		//\dur, 2 * ~sequenceTempo,
		\octave, 6,
		\amp, 0.1
	),

	Pbind( //Bass sound
		\instrument, \bass_tone,
		\scale, Pfunc({~pieceScale}),
		\degree, Pseq([~bassNoteDegreeList.at(0), ~bassNoteDegreeList.at(1),
					~bassNoteDegreeList.at(2), ~bassNoteDegreeList.at(3)], inf),
		\dur, Pseq([~bassNoteDurList.at(0), ~bassNoteDurList.at(1),
				~bassNoteDurList.at(2), ~bassNoteDurList.at(3) ], inf)
		* Pfunc({~sequenceTempo}),
		\amp, Pseq([~bassNoteAmpList.at(0), ~bassNoteAmpList.at(1),
				~bassNoteAmpList.at(2), ~bassNoteAmpList.at(3) ], inf),
		\octave, 4
	),

	Pbind(
		\instrument, \melody_tone0,  //Melody1
		\scale, Pfunc({~pieceScale}),
		\degree, Pseq([~melodyNoteDegreeLists.at(0).at(0), ~melodyNoteDegreeLists.at(0).at(1),
					~melodyNoteDegreeLists.at(0).at(2), ~melodyNoteDegreeLists.at(0).at(3)], inf),
		\dur, Pseq([~melodyNoteDurLists.at(0).at(0), ~melodyNoteDurLists.at(0).at(1),
				~melodyNoteDurLists.at(0).at(2), ~melodyNoteDurLists.at(0).at(3)], inf)
				* Pfunc({~sequenceTempo}),
		\amp, Pseq([~melodyNoteAmpLists.at(0).at(0), ~melodyNoteAmpLists.at(0).at(1),
					~melodyNoteAmpLists.at(0).at(2), ~melodyNoteAmpLists.at(0).at(3)], inf),
		\octave, 5
	),

	Pbind(
		\instrument, \melody_tone1,  //Melody2
		\scale, Pfunc({~pieceScale}),
		\degree, Pseq([~melodyNoteDegreeLists.at(1).at(0), ~melodyNoteDegreeLists.at(1).at(1),
					~melodyNoteDegreeLists.at(1).at(2), ~melodyNoteDegreeLists.at(1).at(3)], inf),
		\dur, Pseq([~melodyNoteDurLists.at(1).at(0), ~melodyNoteDurLists.at(1).at(1),
				~melodyNoteDurLists.at(1).at(2), ~melodyNoteDurLists.at(1).at(3)], inf)
				* Pfunc({~sequenceTempo}),
		\amp, Pseq([~melodyNoteAmpLists.at(1).at(0), ~melodyNoteAmpLists.at(1).at(1),
					~melodyNoteAmpLists.at(1).at(2), ~melodyNoteAmpLists.at(1).at(3)], inf),
		\octave, 6
	),
	Pbind(
		\instrument, \arpeggio_tone, //Arpeggio
		\scale, Pfunc({~pieceScale}),
		\degree, Pseq([~arpeggioNoteDegreeList.at(0), ~arpeggioNoteDegreeList.at(1),
					~arpeggioNoteDegreeList.at(2), ~arpeggioNoteDegreeList.at(3)], inf),
		\dur, Pseq([~arpeggioNoteDurList.at(0), ~arpeggioNoteDurList.at(1),
				~arpeggioNoteDurList.at(2), ~arpeggioNoteDurList.at(3)], inf) *Pfunc({~sequenceTempo}),
		\amp, Pseq([~arpeggioNoteAmpList.at(0), ~arpeggioNoteAmpList.at(1),
				~arpeggioNoteAmpList.at(2), ~arpeggioNoteAmpList.at(3)], inf),
		\ratio, Pfunc({~arpeggioToneColor}),
		\octave, 6
	),

	// Internal Effect /////////////////////////////////////////////////

	~internalEffect1 =
		Pfx(~textureBaseSound1Pbind, \internalEffect1,
		\param0, Pfunc({~internalEffectParamList.at(0).at(0)}),
		\param1, Pfunc({~internalEffectParamList.at(0).at(1)}),
		\param2, Pfunc({~internalEffectParamList.at(0).at(2)}),
		\param3, Pfunc({~internalEffectParamList.at(0).at(3)})),
	/*
	~internalEffect2 =
		Pfx(~textureBaseSound2Pbind, \internalEffect2,
		\param0, Pfunc({~internalEffectParamList.at(0).at(0)}),
		\param1, Pfunc({~internalEffectParamList.at(0).at(1)}),
		\param2, Pfunc({~internalEffectParamList.at(0).at(2)}),
		\param3, Pfunc({~internalEffectParamList.at(0).at(3)})),
	*/


	// TextureSounds Effect /////////////////////////////////////////////////

	~textureSound1 =
		Pfx(~textureBaseSound1Pbind, \textureEffect1,
		\param0, Pfunc({~textureEffectParamList.at(0).at(0)}),
		\param1, Pfunc({~textureEffectParamList.at(0).at(1)}),
		\param2, Pfunc({~textureEffectParamList.at(0).at(2)}),
		\param3, Pfunc({~textureEffectParamList.at(0).at(3)})),

	~textureSound2 =
		Pfx(~textureBaseSound2Pbind, \textureEffect2,
		\param0, Pfunc({~textureEffectParamList.at(1).at(0)}),
		\param1, Pfunc({~textureEffectParamList.at(1).at(1)}),
		\param2, Pfunc({~textureEffectParamList.at(1).at(2)}),
		\param3, Pfunc({~textureEffectParamList.at(1).at(3)})),

	~textureSound3 =
		Pfx(~textureBaseSound3Pbind, \textureEffect3,
		\param0, Pfunc({~textureEffectParamList.at(2).at(0)}),
		\param1, Pfunc({~textureEffectParamList.at(2).at(1)}),
		\param2, Pfunc({~textureEffectParamList.at(2).at(2)}),
		\param3, Pfunc({~textureEffectParamList.at(2).at(3)})),

	~textureSound4 =
		Pfx(~textureBaseSound4Pbind, \textureEffect4,
		\param0, Pfunc({~textureEffectParamList.at(3).at(0)}),
		\param1, Pfunc({~textureEffectParamList.at(3).at(1)}),
		\param2, Pfunc({~textureEffectParamList.at(3).at(2)}),
		\param3, Pfunc({~textureEffectParamList.at(3).at(3)})),


	// Position Sender //////////////////////////////////////////////////////
	Pbind(
		\instrument, \positionSender,
		[\cb, \prm], Pseq([ [0,0], [1,1], [2,2], [3,3] ], inf),
		\dur, Pfunc({4 * ~sequenceTempo})
	)

]).play;
};

~stopSound = {"stopSound".postln; x.stop;};
)