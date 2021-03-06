(

// Scale
~pieceScale = Scale.harmonicMinor;

// Tempo
~sequenceTempo = 0.25;


// SynthDef /////////////////////////////////////////////////////////////////////////////

SynthDef("testSine", {arg amp=0.1, freq=440;
Out.ar([0,1], SinOsc.ar(freq*2, 0, amp*EnvGen.ar(Env.perc, doneAction:2)));
}).store;

//variation with more sines
SynthDef(\percussion_tone1, {arg amp= 0.5, decay= 0.1, freq= 60;
	var env, snd;
	env = EnvGen.ar(Env.perc(0, decay), doneAction:2);
	snd = Mix(SinOsc.ar([freq, freq*2, freq-15], 0, amp));
	Out.ar(0, Pan2.ar(snd*env, 0));
}).store;

SynthDef(\percussion_tone2, {arg gate=1, note=60, amp=1, pan=0, outBus=0;
	var x, env1, env2, env3, mod, noise;
	
	//http://supercollider.jp/modules/xhnewbb/viewtopic.php?topic_id=94&viewmode=flat&order=DESC&move=prev&topic_time=1183036602
	
	env1 = Env.perc(0.001,0.15,1,-4);
	env2 = Env.perc(0.001,0.01,1,-4);
	env3 = Env.perc(0.0001,0.01,0.2,-10);
	mod = EnvGen.ar(env2,gate) * 100;
	noise = EnvGen.ar(env3,gate);
	x = SinOsc.ar((note-24).midicps + mod, 0, amp);
	x = EnvGen.ar(env1,gate,doneAction: 2) * x - noise;
	Out.ar(0, Pan2.ar(x,pan));
}).store;


/*
SynthDef(\percussion_tone2, {arg gate=1, note=60, amp=1, pan=0, outBus=0;
	//コムフィルタによるエフェクト有り
	var x, env1, env2, env3, mod, noise, effectedSnd;
	
	//http://supercollider.jp/modules/xhnewbb/viewtopic.php?topic_id=94&viewmode=flat&order=DESC&move=prev&topic_time=1183036602
	
	env1 = Env.perc(0.001,0.15,1,-4);
	env2 = Env.perc(0.001,0.01,1,-4);
	env3 = Env.perc(0.0001,0.01,0.2,-10);
	mod = EnvGen.ar(env2,gate) * 100;
	noise = EnvGen.ar(env3,gate);
	x = SinOsc.ar((note-24).midicps + mod, 0, amp);
	x = EnvGen.ar(env1,gate,doneAction: 2) * x - noise;
	//Out.ar(outBus, Pan2.ar(x,pan));
	
	effectedSnd = CombN.ar(Pan2.ar(x, pan), 0.1, 0.01, 0.5);
	Out.ar(0, effectedSnd);
	
}).store;
*/

SynthDef(\percussion_tone3, {arg freq=440, gate=1;
	Out.ar(0, Pan2.ar(
		BPF.ar(LFPulse.ar(BPF.ar(WhiteNoise.ar(5), 12000, 0.1).distort * 8000 + 6600, 0.7), 7000, 1)
		* EnvGen.kr(Env.perc(0.01, 0.4, 1, -6), doneAction:2), 0));
}).store;

//variation with snds with differenct envelopes
/*
SynthDef(\percussion_tone0, {|amp=0.5, decay=0.3, freq=1000|
	var env, snd, env2, snd2;
	env = EnvGen.ar(Env.perc(0, decay), doneAction:2);
	env2 = EnvGen.ar(Env.perc(0.05, decay*0.5));
	snd = RLPF.ar(GrayNoise.ar(amp), freq, Line.ar(0.1, 0.9, decay));
	snd2 = WhiteNoise.ar(amp)*env2;
	Out.ar(0, Pan2.ar(snd + snd2 * env, 0));
}).store;
*/

SynthDef(\percussion_tone0, {|amp=0.5, decay=0.3, freq=1000|
	//フィードバックディレイのエフェクト有り
	var env, snd, env2, snd2, nonEffectedSnd, effectedSnd, fb;
	env = EnvGen.ar(Env.perc(0, decay), doneAction:2);
	env2 = EnvGen.ar(Env.perc(0.05, decay*0.5));
	snd = RLPF.ar(GrayNoise.ar(amp), freq, Line.ar(0.1, 0.9, decay));
	snd2 = WhiteNoise.ar(amp)*env2;
	nonEffectedSnd = Pan2.ar(snd + snd2 * env, 0);
	
	fb = LocalIn.ar(2);
	effectedSnd = DelayN.ar(nonEffectedSnd + fb, ~sequenceTempo * 0.25, ~sequenceTempo * 0.25);
	LocalOut.ar(effectedSnd * 0.8);

	Out.ar(0, nonEffectedSnd);
}).store;


SynthDef(\melody_tone0, {|freq=400, out=0, releaseT=0.3, amp=0.8|
 var source; 
 source = SinOsc.ar(freq) * EnvGen.ar(Env.perc(0.0001, releaseT, 1, -6), doneAction:2) * amp; 
 Out.ar(0, source);
}).store;


/*
SynthDef(\melody_tone0, {|freq=400, out=0, releaseT=0.3, amp=0.8|
	//Add Flanger メモリ食い過ぎらしいが，何か間違いがあるのだろうか．
 var source, mod; 
 source = SinOsc.ar(freq) * EnvGen.ar(Env.perc(0.0001, releaseT, 1, -6), doneAction:2) * amp; 
 mod = SinOsc.ar(0.3, 0, 0.001);
 out = DelayN.ar(source, 1, [0.001, 0.001+mod]) + source;
 Out.ar(0, out);
 
 //Out.ar(0, source);
 
}).store;
*/

SynthDef(\bass_tone, {arg freq=440, gate=1, amp=1, pan=0, outBus=0;
	var env1,env2,env3,mod1,mod2,x;
	/*
	http://supercollider.jp/modules/xhnewbb/viewtopic.php?topic_id=195&viewmode=flat&order=DESC
	*/
	env1 =Env.adsr(0.001,0.01,0.7,0.2,1,-4);
	env2 =Env.perc(0.001,10,1,-1);
	env3 =Env.perc(0.001,0.1,1,-4);
	mod1 =EnvGen.kr(env2,gate)*SinOsc.ar(freq*0.5,0,pi*0.25);
	mod2 =EnvGen.kr(env3,gate)*LFNoise0.ar(700,50);
	x = SinOsc.ar(freq+mod2,mod1,amp)*EnvGen.ar(env2,gate);
	x = EnvGen.kr(env1,gate,doneAction:2)*x;
	Out.ar(outBus,Pan2.ar(x,pan));
}).store;


SynthDef(\harmony_tone, {arg freq = 360, gate = 1, pan = 0.0, amp = 0.1, attack = 1.0, sustain = 2.0, releaseTime = 1.0;

	var out, eg, fc, osc, a, b, w;
	fc = LinExp.kr(LFNoise1.kr(Rand(0.25,0.3)), -1,1,500,2000);
	// fc = 20000;
	osc = Mix.fill(2, {SinOsc.ar(freq * [Rand(0.99,1.01),Rand(0.99,1.01)], 0, amp) }) .distort* 0.2 ;
	// eg = EnvGen.kr(Env.perc(attack, releaseTime, 1, -4), gate, doneAction:2) * LFSaw.kr(Line.kr(1,10,2),0, 0.5, 0.5);
	eg = EnvGen.kr(Env.perc(attack, releaseTime, 1, -4), gate, doneAction:2) * LFSaw.kr(Line.kr(1,10,2),0, 0.5, 0.5);
	out = eg * RLPF.ar(osc, fc, 0.1);
	#a, b = out;
	Out.ar(0, Mix.ar(PanAz.ar(2, [a, b], [pan, pan+0.3]))); }).store;



SynthDef(\up_piano, {arg freq=440, gate=1, amp=1, pan=0, width=0.5, pulse=0.3;  

	var x, env, lfo;  

	env = Env.adsr(0.01,0.2,0.5,0.2, -3);  
	lfo = Pulse.ar(freq*2,width,amp*pulse);  
	x = SinOsc.ar([freq,freq+2],0,amp-pulse,lfo);  
	x = EnvGen.kr(env,gate,doneAction: 2) * x;  
	Out.ar(0, Pan2.ar(x,pan));  
}).store;


SynthDef(\melodySaw, {arg out=0, gate=1, freq=200, amp=0.5;
	/* http://supercollider.jp/blog/?p=565 */
	//現状メモリリーク注意 →おそらく解消
	var aEnv, fEnv, osc, flt;
	aEnv = EnvGen.kr(Env.asr(0.1, 0.8, 1), gate, doneAction:2);
	fEnv = EnvGen.kr(Env.adsr(0.4, 1.2, 0.7, 2), gate, 800, doneAction:2);
	osc = SinOsc.ar(Lag.kr(freq, 0.1) * [1, 1.001]) * 0.5; //Saw
	flt = LPF.ar(osc, fEnv + 600, aEnv*amp); 	Out.ar(out, flt); }).store;
	
SynthDef(\simpleSaw, {arg freq=400, out=0, releaseT=0.3, amp=0.8;
	var source;
	source = Saw.ar(freq) * EnvGen.ar(Env.perc(0.0001, releaseT, 1, -6), doneAction:2) * amp;
	Out.ar(out, source);
}).store;

SynthDef(\melody_tone1, {arg freq=440, gate=10, amp=0.5, env, source1, source2, pan = 0.0 ;
	/* http://d.hatena.ne.jp/deezel/20110218/1297980810 */
	env = EnvGen.kr(Env.adsr(0.001, 2, 0.0, 0.1, 1, -20), gate, doneAction:2);
	source1 = Pan2.ar( Pulse.ar(freq, 0.51, amp) * env );
	2.do({source1 = AllpassN.ar(source1, 0.08, [ExpRand(0.01,05.5),ExpRand(0.01,5.08)], 2)});
	source2 = source1 + Pan2.ar( Pulse.ar(freq*2, 0.51, amp) * env );
	Out.ar(0, source2);
}).store;

/*
SynthDef(\melody_tone1, {arg freq=440, gate=1, amp=1.0, source, env1, env2, pan = 0.0 ;
	// http://d.hatena.ne.jp/deezel/20110218/1297980810 
	env1 = EnvGen.kr(Env.adsr(0.001, 1, 0.0, 0.6, 1, -6), gate, doneAction:2);
	env2 = EnvGen.kr(Env.adsr(0.01, 0.2, 0.0, 0.2, 1, Rand(-50,-10)), gate, ExpRand(40,13000), 400);
	source = Pan2.ar(LPF.ar(LFSaw.ar(freq, [Rand(0,1),Rand(0,1)], amp), env2) * env1, pan);
	2.do({source = AllpassN.ar(source, 0.07, ExpRand(0.01,0.07), 3)});
	Out.ar(0, source);
}).store;
*/

/*
SynthDef(\melody_tone1, {arg freq=440, gate=1, amp=1.0, source, env1, env2, pan = 0.0 ;
	// http://d.hatena.ne.jp/deezel/20110218/1297980810 
	//Add Flanger メモリ不足
	var mod, outSnd;
	env1 = EnvGen.kr(Env.adsr(0.001, 1, 0.0, 0.6, 1, -6), gate, doneAction:2);
	env2 = EnvGen.kr(Env.adsr(0.01, 0.2, 0.0, 0.2, 1, Rand(-50,-10)), gate, ExpRand(40,13000), 400);
	source = Pan2.ar(LPF.ar(LFSaw.ar(freq, [Rand(0,1),Rand(0,1)], amp), env2) * env1, pan);
	2.do({source = AllpassN.ar(source, 0.07, ExpRand(0.01,0.07), 3)});
	
	mod = SinOsc.ar(0.3, 0, 0.001);
	outSnd = DelayN.ar(source, 1, [0.001, 0.001+mod]);

	Out.ar(0, outSnd);
}).store;
*/

SynthDef(\sampleFm, {arg freq=440, amp=1, mfreq=440, mamp=1, gate=1, pan=0;
	/*
	http://supercollider.jp/modules/xhnewbb/viewtopic.php?topic_id=2&viewmode=flat&order=DESC&move=next&topic_time=1159712165
	*/

	var car, mod, env;
	mod = SinOsc.ar(mfreq, 0, mamp);
	car = SinOsc.ar(freq+mod, 0, amp);
	env = Env.adsr(0.1,0.2,0.5,1,1,-3);
	car = EnvGen.kr(env,gate,doneAction: 2) * car;
	Out.ar(0, Pan2.ar(car,pan));
}).store;


SynthDef(\arpeggio_tone, {arg freq=440, amp=1.2, ratio=1, mindex=1, gate=1, pan=0;  
	
	//http://supercollider.jp/modules/xhnewbb/viewtopic.php?topic_id=2&viewmode=flat&order=DESC&move=next&topic_time=1159712165
	
	var car, mod, env, mfreq,mamp;  
	mfreq = freq*ratio;  
	mamp = mfreq*mindex;  
	mod = SinOsc.ar(mfreq, 0, mamp);  
	car = SinOsc.ar(freq+mod, 0, amp);  
	env = Env.adsr(0.1,0.2,0.5,1,1,-3);  
	car = EnvGen.kr(env,gate,doneAction: 2) * car;  
	Out.ar(0, Pan2.ar(car,pan));  
}).store;  

/*
SynthDef(\arpeggio_tone, {arg freq=440, amp=1, ratio=1, mindex=1, gate=1, pan=0;  
	
	//http://supercollider.jp/modules/xhnewbb/viewtopic.php?topic_id=2&viewmode=flat&order=DESC&move=next&topic_time=1159712165
	//Add Flanger
	var car, mod, env, mfreq,mamp, source, mod2, outSnd;  
	mfreq = freq*ratio;  
	mamp = mfreq*mindex;  
	mod = SinOsc.ar(mfreq, 0, mamp);  
	car = SinOsc.ar(freq+mod, 0, amp);  
	env = Env.adsr(0.1,0.2,0.5,1,1,-3);  
	car = EnvGen.kr(env,gate,doneAction: 2) * car;  
	source = Pan2.ar(car, pan);
	mod2 = SinOsc.ar(0.3, 0, 0.001);
	outSnd = DelayN.ar(source, 1, [0.001, 0.001+mod2]) + source;

	Out.ar(0, outSnd);  
}).store;  
*/


// PatternMaker ///////////////////////////////////////////////////////////////////////////



// Rhythm Pattern
~rhythmPatterns = List.new;

//Default (inputValue == 0.0)
// freq [1000, 750, 1250, 2000, 200]

~rhythmPatterns.add( //Percussion0: Snare
	List[ // order: \freq, \dur, amp
	[[\reste, 2, 0.2], [\reste, 2, 0.2]],
	[[\reste, 1, 0.5], [1000, 1, 0.2], [\reste, 1, 0.9], [750, 1, 0.3]],
	[[\reste, 1, 0.3], [1250, 1, 0.3], [\reste, 0.5, 0.2], [2000, 1, 0.2], [200,0.5, 0.2]],
	[[\reste, 0.5, 0.5], [2000, 1, 0.2], [200, 0.5, 0.3], [\reste, 1, 0.5], [1250, 1, 0.2]],
	[[200, 0.5, 0.9], [750, 0.5, 0.5], [1250, 1, 0.3], [\reste, 0.5, 0.2], [1000, 1.5, 0.4]],
	[[2000, 0.5, 0.4], [\reste, 1, 0.2], [200, 0.5, 0.6],[2000, 0.5, 0.4], [\reste, 1, 0.5], [200,0.5, 0.9]]
]);

~rhythmPatterns.add( //Percussion1: Kick
	 List [ //order: \freq, \dur, \amp //freq 60, 80
	[[60, 1, 1], [80, 1, 1], [80, 1, 1], [80, 1, 1]]
]);

/*
~rhythmPatterns.add( //Percussion1: Kick
	 List [ //order: \freq, \dur, \amp //freq 200, 300, 400, 900
	 [[\reste, 2, 0.3], [\reste, 2, 0.3]],
	[[200, 1, 0.3], [200, 1, 0.3], [200, 1, 0.3], [200, 1, 0.3]],
	[[200, 1, 0.3], [200, 1, 0.3], [200, 1, 0.3], [200, 1, 0.3]],
	[[200, 1, 0.3], [\rest, 3, 0.3]],
	[[300, 1, 0.3], [\rest, 1, 0.3], [400, 1, 0.3], [\rest, 1, 0.3]],
	[[200, 1, 0.3], [300, 1, 0.3], [400, 1, 0.3], [\rest, 1, 0.3]],
	[[900, 0.5, 0.3], [200, 0.5, 0.3], [300, 1, 0.3], [400, 1, 0.3], [\rest, 1, 0.3]],
	[[900, 1, 0.3], [200, 0.5, 0.3], [300, 0.5, 0.3], [400, 1, 0.3], [\rest, 1, 0.3]],
	[[900, 1, 0.3], [\rest, 1, 0.3], [200, 0.5, 0.3], [300, 0.5, 0.3], [400, 1, 0.3]],
	[[400, 1, 0.3], [\rest, 1, 0.3], [300, 1, 0.3], [200, 0.5, 0.3], [900, 0.5, 0.3]],
	[[900, 1, 0.3], [200, 1, 0.3], [300, 1, 0.3], [400, 1, 0.3]]
]);
*/

~rhythmPatterns.add( //Percussion2: Kick-Electro
	 List [ //order: \octave, \degree, \dur, amp //freq 200, 300, 400, 900
	[[4, 0, 1, 1], [2, 0, 1, 1], [2, 0, 1, 1], [2, 0, 1, 1]],
	[[4, 0, 1, 1], [2, 0, 1, 1], [2, 0, 1, 1], [2, 0, 1, 1]],
	[[4, 0, 1, 1], [2, 0, 1, 1], [2, 0, 1, 1], [2, 0, 1, 1]],
	[[4, 0, 1, 1], [2, \rest, 3, 1]],
	[[4, 0, 1, 1], [2, \rest, 1, 1], [2, 0, 1, 1], [2, \rest, 1, 1]],
	[[4, 0, 1, 1], [2, 0, 1, 1], [2, 0, 1, 1], [2, \rest, 1, 1]],
	[[4, 0, 0.5, 1], [2, 0, 0.5, 1], [2, 0, 1, 1], [2, 0, 1, 1], [2, \rest, 1, 1]],
	[[4, 0, 1, 1], [2, 0, 0.5, 1], [2, 0, 0.5, 1], [2, 0, 1, 1], [2, \rest, 1, 1]],
	[[4, 0, 1, 1], [2, \rest, 1, 1], [2, 0, 0.5, 1], [2, 0, 0.5, 1], [2, 0, 1, 1]],
	[[4, 0, 1, 1], [2, \rest, 1, 1], [2, 0, 1, 1], [2, 0, 0.5, 1], [2, 0, 0.5, 1]],
	[[4, 0, 1, 1], [2, 0, 1, 1], [2, 0, 1, 1], [2, 0, 1, 1]]
]);

~rhythmPatterns.add( //Percussion3: Hat
	 List [ //order: \freq, \dur, \amp //freq 4000, 6000, 8000, 2000
	 [[\reste, 2, 0.5], [\reste, 2, 0.5]],
	[[\rest, 1, 0.5], [6000, 1, 0.5], [\rest, 1, 0.5], [8000, 1, 0.5]],
	[[4000, 1, 0.5], [\rest, 1, 0.5], [6000, 1, 0.5], [\rest, 1, 0.5]]
]);
	
//Regist Default Pattern : all 0.0
~rhythmNoteLists = List.new();
for(0, 3, {arg i;
	var noteList = List.new();
	for(0, 3, {
		noteList.add( PatternProxy( Pseq( ~rhythmPatterns.at(i).at(0) )));
	});
	~rhythmNoteLists.add(noteList);
});

//Dynamic Pattern Change	
~rhythmNoteInserter = { arg indexInMap; //inputValue: 0 <= x <=1
	for(0, 3, {arg positionIndex;
		var inputDegree = (~valueListForGeneration.at(1).at(indexInMap).at(positionIndex) 
			* (~rhythmPatterns.at(indexInMap).size * 1.0)).floor;
		~rhythmNoteLists.at(indexInMap).at(positionIndex).source = 
			(Pseq( ~rhythmPatterns.at(indexInMap).at(inputDegree)));
	});
};


//Malody Pattern

~melodyNoteDegreeLists = List.new;
for(0,2,{
	var aPart = List.new;
	for(0,3,{aPart.add(PatternProxy(Pseq([\reste,\reste])));});
	~melodyNoteDegreeLists.add(aPart);
});

~melodyNoteDurLists = List.new;
for(0,2,{
	var aPart = List.new;
	for(0,3,{aPart.add(PatternProxy(Pseq([2,2])));});
	~melodyNoteDurLists.add(aPart);
});

~melodyNoteAmpLists = List.new;
for(0, 2, {
	var aPart = List.new;
	for(0, 3, {aPart.add(PatternProxy(Pseq([0.5, 0.5])));});
	~melodyNoteAmpLists.add(aPart);
});


~bassNoteDegreeList = List.new;
for(0,3, {arg i; 
	~bassNoteDegreeList.add(PatternProxy(Pseq([\reste, \reste])));});
~bassNoteDurList = List.new;
for(0,3,{~bassNoteDurList.add(PatternProxy(Pseq([4])));});
~bassNoteAmpList = List.new;
for(0, 3, {arg i;
	~bassNoteAmpList.add(PatternProxy(Pseq([1])));});


~arpeggioSequenceForm = List [
	[-1, -1, -1, -1],
	[0, 1, 2, 3],
	[0, 1, 2, 3],
	[0, 2, 1, 3],
	[0, 3, 1, 2],
	[3, 0, 2, 1],
	[3, 2, 1, 0]
];
~arpeggioSequenceDurationForm = List [0.25, 0.25, 0.5, 1];
~arpeggioSequenceOctaveRepetition = List[1, 2, 4];
~arpeggioToneColorList = List [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 ];

~arpeggioNoteDegreeList = List.new;
~arpeggioNoteDurList = List.new;
for(0, 3, {~arpeggioNoteDegreeList.add(PatternProxy(Pseq([\reste, \reste, \reste, \reste])));});
for(0, 3, {~arpeggioNoteDurList.add(PatternProxy(Pseq([1, 1, 1, 1])));});
~arpeggioToneColor = ~arpeggioToneColorList.at(0);

~melodyNoteInserter = {arg indexInMap;
	var degreeList, durationList;

	for(0, 3, {arg positionIndex;
		var newDegreeList = List.new;
		var harmonyNotes = List.new;
		
		degreeList = ~sequenceValueListForGeneration.at(2).at(indexInMap).at(positionIndex).copy;
		durationList = ~sequenceDurationListForGeneration.at(2).at(indexInMap).at(positionIndex).copy;
		harmonyNotes.add(~harmonyBasePitchDegree.at(positionIndex*2));
		harmonyNotes.add(~harmonySecondPitchDegree.at(positionIndex*2));
		harmonyNotes.add(~harmonyThirdPitchDegree.at(positionIndex*2)-7);
		harmonyNotes.add(~harmonyForthPitchDegree.at(positionIndex*2)-14);

		if((indexInMap <= 2), { //Normal Melodies

			degreeList.do({arg item, i; 
				if((item.isNumber),
					{newDegreeList.add((item * 17).floor + harmonyNotes.(i));},
					{newDegreeList.add(\reste);}	
				);
			});
			
			//newDegreeList.postln;
			~melodyNoteDegreeLists.at(indexInMap).at(positionIndex).source = (Pseq(newDegreeList));

			~melodyNoteDurLists.at(indexInMap).at(positionIndex).source = (Pseq(durationList));
		});
		
		if((indexInMap == 2), {~arpeggioNoteInserter.value(indexInMap);});

		if((indexInMap == 3), { //Bass Melodies
			degreeList.do({arg item, i; 
				if((item.isNumber), {newDegreeList.add(harmonyNotes.at((item * 4).floor));},
					{newDegreeList.add(\reste);}
				);
			});
			newDegreeList.put(0,harmonyNotes.at(0));
			//newDegreeList.post; " ".post; durationList.postln;
		
			~bassNoteDegreeList.at(positionIndex).source = (Pseq(newDegreeList));
			~bassNoteDurList.at(positionIndex).source = (Pseq(durationList));
		});
	});
};

~arpeggioNoteAmpList = List.new;
for(0, 3, {arg i;
	~arpeggioNoteAmpList.add(PatternProxy(Pseq([1.2])));});

~arpeggioNoteInserter = {arg indexInMap; // Arpeggio Melodies
	var sequenceForm;
	var sequenceDuration;
	var sequenceOctaveRepetition;
	var argForArpeggio = List.new;
	var temp;

	//Actually indexInMap is not used
	//Generate Arpeggio phrase from 3 values of melodies
	~valueListForGeneration.at(2).at(2).do({arg item; argForArpeggio.add(item);});
	//argForArpeggio.postln;

	sequenceForm = ~arpeggioSequenceForm.at((argForArpeggio.at(0) * ~arpeggioSequenceForm.size).floor);
	temp = (argForArpeggio.at(1) * ~arpeggioSequenceDurationForm.size).floor;	sequenceDuration = ~arpeggioSequenceDurationForm.at(temp);
	sequenceOctaveRepetition = ~arpeggioSequenceOctaveRepetition.at((argForArpeggio.at(2) * ~arpeggioSequenceOctaveRepetition.size).floor);
			
	~arpeggioToneColor = ~arpeggioToneColorList.at((argForArpeggio.at(3) * ~arpeggioToneColorList.size).floor);
				
	for(0, 3, {arg positionIndex;
		var degreeCandidateList = List.new;
		var degreeList = List.new;
		var durationList = List.new;
		var durationCounter = 0;
		var counter = 0;
		var newList;
		
		degreeCandidateList = List.new;
		degreeCandidateList.add(~harmonyBasePitchDegree.at(positionIndex*2));
		degreeCandidateList.add(~harmonySecondPitchDegree.at(positionIndex*2));
		degreeCandidateList.add(~harmonyThirdPitchDegree.at(positionIndex*2));
		degreeCandidateList.add(~harmonyForthPitchDegree.at(positionIndex*2));
		for(0, degreeCandidateList.size-1, {arg i;
			while({degreeCandidateList[i] >= 7},
				{degreeCandidateList[i] = degreeCandidateList[i] - 7;});
		});
		degreeCandidateList = degreeCandidateList.sort;

		//"degreeCandidateList is: ".post; degreeCandidateList.postln;
		while({durationCounter < 4}, {
			durationList.add(sequenceDuration);
			durationCounter = durationCounter + sequenceDuration;
		});
		durationCounter = 0;
		counter = 0;
		durationList.do({
			if((sequenceForm.at(counter) >= 0),
				{degreeList.add(degreeCandidateList.at(sequenceForm.at(counter)));},
				{degreeList.add(-1);});
			counter = counter + 1;
			if((counter >= sequenceForm.size), {counter = 0;});
		});
		
		//"degreeList is:".post; degreeList.postln;
		//"durationList is:".post; durationList.postln;

		if((sequenceDuration < 1), { //When 8th and 16th
			switch(sequenceOctaveRepetition,
				2, { case // Only up
					{ sequenceDuration == 0.25 } // 4 time repetition
					{ degreeList.do({arg item, i;
							if((item >= 0), {
								case 
									{i < 4} { degreeList[i] = degreeList[i];}
									{i < 8} { degreeList[i] = degreeList[i] + 7;}
									{i < 12} { degreeList[i] = degreeList[i] + 14;}
									{degreeList[i] = degreeList[i] + 21};
							});
						});
					}
					{ sequenceDuration == 0.5 } // 2 time repetition
					{ for(4, 7, {arg i; if((degreeList[i] >= 0), {degreeList[i] = degreeList[i] +  7;});});}
				},
				4, { case // up then down
					{ sequenceDuration == 0.25 } // 2 time up then 2 time down
					{ 
						newList = List.new;
						for(9, 11, {arg i; newList.add(degreeList.at(i))});
						for(9, 11, {arg i; degreeList.put(i, newList.pop);});
						for(13, 15, {arg i; newList.add(degreeList.at(i));});
						for(13, 15, {arg i; degreeList.put(i, newList.pop);});
						
						degreeList.do({arg item, i;
							if((item >= 0), {
								case
									{i < 4} { degreeList[i] = degreeList[i];}
									{i < 8} { degreeList[i] = degreeList[i] + 7;}
									{i == 8 } { degreeList[i] = degreeList[i] + 14;}
									{i <= 12 } { degreeList[i] = degreeList[i] + 7;}
									{ degreeList[i] = degreeList[i];};
							});
						});
					}
					{ sequenceDuration == 0.5 } // 1 time up then 1 time down
					{ 
						newList = List.new;
						for(0, 3, {newList.add(degreeList.pop);});
						newList.reverse;
						newList.do({arg item; degreeList.add(item);});
					};
				}
			);
		});	
		degreeList.do({arg item, i; if((item < 0), {degreeList[i] = \reste;})});

		~arpeggioNoteDegreeList.at(positionIndex).source = Pseq(degreeList);
		~arpeggioNoteDurList.at(positionIndex).source = Pseq(durationList);
	});
};

)