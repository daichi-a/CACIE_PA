(

~gpEngineAddr = NetAddr("localhost", 57120);
~guiAddr = NetAddr("localhost", 12000);

~initPhotoMusicGP = {
//Add Function Nodes
~defineFunctionNode.value(~func_plus = {arg a, b; if(a === €sCount, -1, a + b);};);
~defineFunctionNode.value(~func_minus = {arg a, b; if(a === €sCount, -1, a - b);};);
~defineFunctionNode.value(~func_mult = {arg a, b; if(a === €sCount, -1, a * b);};);
~defineFunctionNode.value(~func_div = {arg a, b; if(a === €sCount, -1, a / b);};);
~defineFunctionNode.value(~func_increment = {arg a; if(a === €sCount, 0, a + 1);};);
~defineFunctionNode.value(~func_decrement = {arg a; if(a === €sCount, 0, a - 1);};);


//Add Terminal Nodes
~defineVariableTerminalNode.value(€rPerc0, 0.01);
~defineVariableTerminalNode.value(€rPerc1, 0.01);
~defineVariableTerminalNode.value(€gPerc0, 0.01);
~defineVariableTerminalNode.value(€gPerc1, 0.01);
~defineVariableTerminalNode.value(€bPerc0, 0.01);
~defineVariableTerminalNode.value(€bPerc1, 0.01);

for(0, 3, {arg i;~defineStaticTerminalNode.value(i*0.1);});
};

~oscPhotoMusicInitEngine.remove;
~oscPhotoMusicInitEngine = OSCresponderNode(nil, '/CACIE_PA/CellAutomata/Controller/init/GPEngine', {
	~initialPhaseGPEngine.value;
	~initPhotoMusicGP.value;
}).add;

~oscPhotoMusicInitChildren.remove;
~oscPhotoMusicInitChildren = OSCresponderNode(nil, '/CACIE_PA/CellAutomata/Controller/init/children', {
	~initChildren.value;
}).add;

~oscPhotoMusicReproduction.remove;
~oscPhotoMusicReproduction = OSCresponderNode(nil, '/CACIE_PA/CellAutomata/Controller/reproduction', {
	~reproduction.value;
}).add;

~oscSetPhotoInformation.remove;
~oscSetPhotoInformation = OSCresponderNode(nil, '/CACIE_PA/PhotoMusic/Controller/setPhotoInformation', {
	arg t, r, msg;

	//msg.postln;

	for(0,3,{arg i;
		~setValueOfVariableTerminalNode.value(€rPerc0, i, msg[1+(i*6)]);
		~setValueOfVariableTerminalNode.value(€rPerc1, i, msg[1+(i*6)+1]);
		~setValueOfVariableTerminalNode.value(€gPerc0, i, msg[1+(i*6)+2]);
		~setValueOfVariableTerminalNode.value(€gPerc1, i, msg[1+(i*6)+3]);
		~setValueOfVariableTerminalNode.value(€bPerc0, i, msg[1+(i*6)+4]);
		~setValueOfVariableTerminalNode.value(€bPerc1, i, msg[1+(i*6)+5]);
	});
	~ontogenyAll.value;
}).add;



~stepCellAutomata = {
	var newCellList;
	var cList = [0, 0, 0];
	var nextState = 0;
	var sumOfNeighborhood = 0;
	var applyingList;

	case
	{~cellAutomataStepRuleCategory === '1D_nonSum_3Neighbor'}
	{
		newCellList = List.new;
		applyingList = ~cellAutomata.at(~cellAutomata.size-1);
		//1D non sum 3 neighbor
		for(0,~cellAutomataSize-1, {arg i;
			//111:7, 110:6, 101:5, 100:4, 011:3, 010:2, 001:1, 000:0
			//Detect neighborhood
			cList[1] = applyingList[i];
			switch(i)
			{0} {cList[0] = applyingList[~cellAutomataSize-1]; cList[2] = applyingList[i+1];}
			{~cellAutomataSize-1} {cList[0] = applyingList[i-1]; cList[2] = applyingList[0];}
			{cList[0] = applyingList[i-1]; cList[2] = applyingList[i+1];};
			
			//Decide Next State
			sumOfNeighborhood = (cList[0] * 4) + (cList[1] * 2) + cList[2];
			nextState = ~cellAutomataStepRule[~cellAutomataStepRule.size - sumOfNeighborhood - 1];
			newCellList.add(nextState);
		});
		~cellAutomata.removeAt(0);
		~cellAutomata.add(newCellList);
	}
	{~cellAutomataStepRuleCategory === '1D_sum_3Neighbor'}
	{
	//1D sum 3 neighbor
	
	}
	{~cellAutomataStepRuleCategory === '2D_nonSum_8Neighbor'}
	{
	//2D non sum 8 neighbor
	
	
	}
	{~cellAutomataStepRuleCategory === '2D_sum_8Neighbor'}
	{
	//2D sum 8 neighbor
	
	
	}
	{~cellAutomataStepRuleCategory === '2D_sum_8Neighbor_itself'}
	{
	//2D sum 8 neighbor and previous state of itself. ex. conway's game of life
	
	
	};
	//applyingList = newCellList;
	//~cellAutomata = newCellList.copy;
	~cellAutomata;
};


~makeStepRuleFromProgramChromosome = {arg programChromosome;
	var pointIndex = 0;
	var newStepRule = List.new;
	var state = 0;
	var numOfCellIn;
	var percentageList = List.new;
	var durationSequenceCounter = 0;
	var percentageOfRoulette;
	var durationSequence = 
		~makeMelodyFromChromosomeString.value(programChromosome, 0, ~cellAutomataStepRuleLength).at(1);
	var allDurationIsMT1 = true;
	durationSequence.do({arg item; if((item < 1), {allDurationIsMT1 = false;});});
	
	if(allDurationIsMT1,{
		durationSequence.do({arg item;
			for(0, (item-1), {newStepRule.add(state.copy);});
			if((state == 0), {state = 1}, {state = 0});
		});
	},
	{
		durationSequence.do({arg item, i;
			if((i==0), 
				{percentageList.add(item.copy);},
				{percentageList.add(item.copy + percentageList.at(i-1));}
			);
		});

		percentageList.do({arg item;
			while({durationSequenceCounter < item},{
				newStepRule.add(state.copy);
				durationSequenceCounter = durationSequenceCounter + 1;
			});
			if((state == 0), {state = 1;}, {state = 0;});
		});
	});
	newStepRule.copy;
};


~initCellAutomataGPEngine = {
~cellAutomataSize = 64;
~cellAutomataDimension = '1D';
~cellAutomataStepRuleCategory = '1D_nonSum_3Neighbor'; // €1D sum8Neibor
~cellAutomataStepRuleLength = 8;
~cellAutomataNumOfState = 2;
~cellAutomataStepRule = [0, 0, 0, 1, 1, 1, 1, 0]; //Rule 30
~cellAutomata;

~cellAutomataStepRuleCategoryDictionary = IdentityDictionary.new;
~cellAutomataStepRuleCategoryDictionary.put('1D_nonSum_3Neighbor', 8);
~cellAutomataStepRuleCategoryDictionary.put('1D_sum_3Neighbor', 4);


};

~setCellAutomataStepRule = {arg rule, ruleCategory; 
	~cellAutomataStepRule = rule;
	~cellAutomataStepRuleCategory = ruleCategory;
	~cellAutomataStepRuleLength = ~cellAutomataStepRuleCategoryDictionary.at(ruleCategory);
};

~setCellAutomataSize = {arg size; ~cellAutomataSize = size;};

~initCellAutomata = {
	var newList;
	~cellAutomata = List.new;
	for(0, ~cellAutomataSize-1, {
		newList = List.new;
		for(0, ~cellAutomataSize-1, {newList.add(~cellAutomataNumOfState.rand);});
		~cellAutomata.add(newList);
	});
	~cellAutomata;
};

~sendCellAutomataStateToGUI = {
	var stateString;
	~cellAutomata.do({arg column, i;
		stateString = String.new;
		column.do({arg item; if(item == 0, {stateString = stateString ++ "0";}, {stateString = stateString ++ "1";})});
		~guiAddr.sendMsg("/CACIE_PA/CellAutomataGUI/cellAutomataState", i, stateString);
	});
};


~stepSignal.remove;
~stepSignal = OSCresponder(nil, '/stepSignal', {arg time, responder, message;
	if(message[3] == 0, {
		~stepCellAutomata.value;
		
		//For Test
		~cellAutomata.at(~cellAutomata.size-1).do({arg item; 
			if(item == 0, {" ".post;}, {"*".post;});
		});
		" ".postln;
		//message[3].postln;
		
	});
	
	~sendCellAutomataStateToGUI.value;
}).add;

SynthDef(€stepSignalCellAutomata, {arg step=0;
	//SendReply.kr(Impulse.kr(0), '/stepSignal', step);
	SendReply.kr(EnvGen.kr(Env.perc, doneAction:2), '/stepSignal', step);
}).store;

~applyIndividualToRuleResponder.remove;
~applyIndividualToRuleResponder = OSCresponderNode(nil, '/CACIE_PA/CellAutomataGPController/applyIndividualToRule', {arg time, responder, message;
	
	
}).add;

)

(
~initCellAutomataGPEngine.value;
~initialPhaseGPEngine.value;
~initPhotoMusicGP.value;
~setCellAutomataSize.value(64);
~initCellAutomata.value;
~setCellAutomataStepRule.value(~makeStepRuleFromProgramChromosome.value(~initSExpr.value(~functionList, ~variableList, ~staticList, -4, 4)), '1D_nonSum_3Neighbor');

)


(
z = Pbind(
		€instrument, €stepSignalCellAutomata,
		€step, Pseq([ 0 ], inf),
		€dur, 1
).play;
)
(
~setCellAutomataStepRule.value(~makeStepRuleFromProgramChromosome.value(~initSExpr.value(~functionList, ~variableList, ~staticList, -4, 4)), '1D_nonSum_3Neighbor');
)

z.stop;
