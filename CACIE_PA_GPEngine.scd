//Linear Genetic Programming //////////////////////////////
(

~initialPhaseGPEngine = {
// Make chromosome list, then fill the list with empty chromosome

~assignList = List.new;
//0:Harmony, 1:Rhythm, 2:Melody 3:External Effects, 4:Internal Effects, 5:Texture Sounds
for(0, 5, {
	var newList = List.new;
	for(0, 3, {newList.add(nil);});
	~assignList.add(newList);
});

// Make chromosome storage for evolution procedure, then fill the list with empty chromosome
~parentsList = List.new(2);
for(0, 1, {arg i; ~parentsList.add(List.new);});
~childrenList = List.new(8);
~genomeStorageList = List.new(8);
for(0, 7, {arg i;
	~childrenList.add(List.new);
	~genomeStorageList.add(List.new);
});

// Make nodes list container
~functionList = List.new;
~staticList = List.new;
~variableList = List.new;
~actualVariableList = MultiLevelIdentityDictionary.new;

~evaluatedValueList = List.new;
//harmony, rhythm, melody, external efx, internal efx, texture
for(0, 5, {arg mapIndex;
	var evaluatedValueInOnePart = List.new;
	for(0, 3, {arg indexInMap;
		var evaluatedValueInOneBox = List.new;
		for(0, 3, {arg positionIndex;
			evaluatedValueInOneBox.add(0.0);
		});
		evaluatedValueInOnePart.add(evaluatedValueInOneBox);
	});
	~evaluatedValueList.add(evaluatedValueInOnePart);
});

};


//Set Node List
//Function Node: Definition
~defineFunctionNode = {arg functionNode;
	~functionList.add(functionNode);
};

//TerminalNode(Variable): Definition and set default value of
~defineVariableTerminalNode = {arg nodeLabel, defaultValue;
	~variableList.add(nodeLabel);
	for(0, 3, {arg positionIndex;
		~actualVariableList.put(nodeLabel, positionIndex, defaultValue);
	});
};

//Terminal Node
~defineStaticTerminalNode = {arg staticValue; ~staticList.add(staticValue);};


//Until Here (Initial Phase) //////////////////////////////


//Evaluator
~evalSExpr = {arg givenList;
	var sumOfStackCount=0, deepestStackCount = 0, evaluatingIndex = 0, subTreeStackCount = 0;
	var subTree = List.new;
	var indexOfFunctions = List.new;
	while(
		{givenList.size > 1},
		{
			sumOfStackCount = 0;
			evaluatingIndex = -1;
			indexOfFunctions.clear;

			//Make Indexes of Function Nodes:
			for(0, givenList.size-1, { arg i;
				if(givenList.at(i).isNumber,
					{sumOfStackCount = sumOfStackCount + 1;},
					{
						sumOfStackCount = sumOfStackCount + givenList.at(i).value(\sCount);
						indexOfFunctions.add(i);
					}
				);
			});


			// Detect Top Node of Subtree to which Evaluate First
			for(0, indexOfFunctions.size-1, {arg i;
				switch(givenList.at(indexOfFunctions.at(i)).value(\sCount),
					-1,
					{if(givenList.at(indexOfFunctions.at(i)+1).isNumber &&
						givenList.at(indexOfFunctions.at(i)+2).isNumber,
						{evaluatingIndex = indexOfFunctions.at(i);}
					)},
					0,
					{if(givenList.at(indexOfFunctions.at(i)+1).isNumber,
						{evaluatingIndex = indexOfFunctions.at(i);}
					)}
				);
			});


			//Detect Subtree to evaluate
			subTree.clear;
			subTreeStackCount = 0;
			while(
				{subTreeStackCount < 1},
				{
					if(givenList.at(evaluatingIndex).isNumber,
						{subTreeStackCount = subTreeStackCount + 1},
						{subTreeStackCount =
							subTreeStackCount + givenList.at(evaluatingIndex).value(\sCount);
						}
					);
					subTree.add(givenList.at(evaluatingIndex));
					givenList.removeAt(evaluatingIndex);
				}
			);


			//Eval Single SubTree

			//ToDo
			//Function Node\̃\\x\\\̒\\\\ւ\\\\s\\
			//Numerical Expression\\ProgN Expression\ŏꍇ\\\\\\\s\\\C\\\s\D

			givenList.insert(evaluatingIndex,
				switch(
					subTree.at(0).value(\sCount),
					-1, {subTree.at(0).value(subTree.at(1), subTree.at(2))},
					0, {subTree.at(0).value(subTree.at(1))}
				)
			)
		}
	);
	List.copyInstance(givenList);
};


//Initializer
~initSExpr = {arg functionList, variableList, staticList, minimumSC, minimumLength;
	var newList = List.new;
	var sumOfStackCount = 0;
	var terminalNodeList = List.new;
	var flagMoreThanMinimum = false;
	var maximumLength = 20;
	var addTerminalNode = false;

	//integrate node lists
	for(0, (variableList.size - 1), {arg i;
		terminalNodeList.add(variableList.at(i));
	});
	for(0, (staticList.size - 1), {arg i;
		terminalNodeList.add(staticList.at(i));
	});

	//Top Node is Function Node
	if((minimumLength != 0),{
		newList.add(functionList.choose);
		sumOfStackCount = newList.at(0).value(\sCount);
	});

	while({sumOfStackCount < 1},{
		if((rrand(0,1) == 1), {addTerminalNode = true;}, {addTerminalNode = false;});

		//Fource to deceide additing nodes
		if(((newList.size <= minimumLength) &&
				(sumOfStackCount > minimumSC) &&
				(sumOfStackCount > -1)),
			{addTerminalNode = false},
			{if((sumOfStackCount < minimumSC ),{addTerminalNode = true;});}
		);

		if((newList.size >= maximumLength), {addTerminalNode = true;});

		if(addTerminalNode,
			{//Case Terminal Node
				newList.add(terminalNodeList.choose);
				sumOfStackCount = sumOfStackCount + 1;
			},
			{//Case Function Node
				newList.add(functionList.choose);
				sumOfStackCount = sumOfStackCount + newList.at(newList.size-1).value(\sCount);
			}
		);
	});


	//check StackCount
	sumOfStackCount = 0;
	for(0,(newList.size-1), {arg i;
		if(((newList.at(i).isNumber) || (newList.at(i).isKindOf(Symbol))),
			{sumOfStackCount = sumOfStackCount + 1;},
			{sumOfStackCount =
				sumOfStackCount + newList.at(i).value(\sCount);}
		);
	});
	if((sumOfStackCount!=1),
		{"Error: sum of stack count is not 1 in Initializer.".postln;
			newList.postln;}
	);

	List.copyInstance(newList);
};


//Crossover
~crossoverSExpr = {arg firstParent, secondParent;
	var parentsList = List.new;
	var crossPointsList = List.new;
	var subTreeList = List.new;
	var sumOfStackCount = 0;
	var subTree;

	//Decice base and sub for crossover, then make copy of chromosome to edit
	if((rrand(0,1) == 0),
		{parentsList.add(List.copyInstance(firstParent));
			parentsList.add(List.copyInstance(secondParent));},
		{parentsList.add(List.copyInstance(secondParent));
			parentsList.add(List.copyInstance(firstParent));}
	);

	for(0,1,{arg i;
		sumOfStackCount = 0;
		subTree = List.new;
		//Decide both crossover point
		crossPointsList.add(rrand(1, parentsList.at(i).size-1));

		//Extract SubTree (also remove the subtree from base tree)
		while({sumOfStackCount < 1}, {
			if(((parentsList.at(i).at(crossPointsList.at(i)).isNumber) ||
				(parentsList.at(i).at(crossPointsList.at(i)).isKindOf(Symbol))),
				{sumOfStackCount = sumOfStackCount + 1;},
				{sumOfStackCount =
					sumOfStackCount +
					parentsList.at(i).at(crossPointsList.at(i)).value(\sCount);}
			);
			subTree.add(parentsList.at(i).at(crossPointsList.at(i)));
			parentsList.at(i).removeAt(crossPointsList.at(i));
		});
		subTreeList.add(subTree);
	});

	//Insert SubTree
	for(0, (subTreeList.at(1).size - 1), {arg i;
		parentsList.at(0).insert(crossPointsList.at(0), subTreeList.at(1).pop);
	});

	//check StackCount
	sumOfStackCount = 0;
	for(0,parentsList.at(0).size-1, {arg i;
		if(((parentsList.at(0).at(i).isNumber) ||
			(parentsList.at(0).at(i).isKindOf(Symbol))),
			{sumOfStackCount = sumOfStackCount + 1;},
			{sumOfStackCount =
				sumOfStackCount + parentsList.at(0).at(i).value(\sCount);}
		);
	});
	if((sumOfStackCount!=1),
		{"Error: sum of stack count is not 1".postln;}
	);

	List.copyInstance(parentsList.at(0));
};

//Mutation
~mutationSExpr = {arg givenList, functionList, variableList, staticList;
	var newList = List.copyInstance(givenList);
	var nodeList = List.new;
	var dumpList = List.new;
	var mutatePoint = rrand(1, (givenList.size - 1));
	var minimumStackCount = 0;
	var sumOfStackCount = 0;
	var newSubTree = List.new;
	var returnedTree = List.new;
	var countOfNewSubTree = 0;

	//Decide Mutation Point and remove a node or subtree on the mutation point.

	sumOfStackCount = 0;
	while({sumOfStackCount < 1},{

		if(((newList.at(mutatePoint).isNumber) ||
			(newList.at(mutatePoint).isKindOf(Symbol))),
			{sumOfStackCount = sumOfStackCount + 1;},
			{sumOfStackCount =
				sumOfStackCount + newList.at(mutatePoint).value(\sCount);}
		);
		newSubTree.add(newList.at(mutatePoint));
		dumpList.add(newList.at(mutatePoint));
		newList.removeAt(mutatePoint);
		countOfNewSubTree = newSubTree.size;

		if((minimumStackCount > sumOfStackCount),
			{minimumStackCount = sumOfStackCount;}
		);
	});

	//Make new subtree. depth of subtree is same as the removed subtree.
	newSubTree = ~initSExpr.value(functionList, variableList, staticList, minimumStackCount, 1);
	//check StackCount
	sumOfStackCount = 0;
	for(0,(newSubTree.size-1), {arg i;
		if(((newSubTree.at(i).isNumber) ||
			(newSubTree.at(i).isKindOf(Symbol))),
			{sumOfStackCount = sumOfStackCount + 1;},
			{sumOfStackCount =
				sumOfStackCount + newSubTree.at(i).value(\sCount);}
		);
	});
	if((sumOfStackCount!=1),
		{"Error: sum of stack count is not 1 in mutation:returndTree.".postln;
			"returnedTree is: ".post; newSubTree.postln;}
	);


	for(0, (newSubTree.size-1), {arg i;
		newList.insert(mutatePoint+i, newSubTree.at(i));
	});

	//check StackCount
	sumOfStackCount = 0;
	for(0,(newList.size-1), {arg i;
		if(((newList.at(i).isNumber) ||
			(newList.at(i).isKindOf(Symbol))),
			{sumOfStackCount = sumOfStackCount + 1;},
			{sumOfStackCount =
				sumOfStackCount + newList.at(i).value(\sCount);}
		);
	});

	if((sumOfStackCount!=1),
		{	" ".postln;
			"Error: sum of stack count is not 1 in mutation:mutatedTree.".postln;
			"Original Tree is : ".post; givenList.postln;
			"Returned SubTree is : ".post; newSubTree.postln;
			"MutatedTree is : ".post; newList.post.postln;

			" ".postln;}
	);

	List.copyInstance(newList);
};


~reproductionMS = {arg parentsList, childrenList, functionList, variableList, staticList;
	var aChild;

	var parent0Size=0, parent1Size=0;
	parent0Size = parentsList.at(0).size;
	parent1Size = parentsList.at(1).size;



	if((parent0Size > 0 && parent1Size == 0),
		{parentsList.put(1, parentsList.at(0));},
		if((parent1Size > 0 && parent0Size == 0),
		{parentsList.put(0, parentsList.at(1));});
	);


	if((parent0Size == 0 && parent1Size == 0),
		{List.copyInstance(childrenList);},
		{
			childrenList.clear();
			for(0, 7, {
				//"Before Crossover".postln;
				aChild = ~crossoverSExpr.value(parentsList.at(0), parentsList.at(1));
				//"Before Mutation".postln;
				childrenList.add(
					~mutationSExpr.value(aChild, functionList, variableList, staticList));

			});
			List.copyInstance(childrenList);
		}
	);
};

~assignIndividualToGenerateMap = {arg mapIndex, indexInMap, fromList, indexInFromList;
	"~assignIndividualToGenerateMap".postln;
	~copyIndividual.value(~assignList.at(mapIndex), indexInMap, fromList, indexInFromList);
	~ontogenyIndividuals.value(mapIndex, indexInMap);
};


~ontogenyIndividuals = {arg mapIndex, indexInMap;
	var evaluatedValueListForThePart, normalizedEvaluatedValueListForThePart,
	inputMax, inputMin, buttomInNormalized = 0.01, topInNormalized = 0.99;
	var convertedList, sendingList;

	// Evaluate S-Expressions, then normalize values, send normalized value to sound engine
	for(0, 3, {arg positionIndex;
		~evaluatedValueList.at(mapIndex).at(indexInMap).put
			(positionIndex,
			~evalSExpr.value(
				~convertVariableStringToNumber.value(
					~assignList.at(mapIndex).at(indexInMap), positionIndex)).at(0));
	});
	//normalization 0 to 1 for all values in the part
	// Do Linear Mapping
	normalizedEvaluatedValueListForThePart = List.new;
	evaluatedValueListForThePart = List.new;
	for(0, 3, {arg indexInMap;
		for(0, 3, {arg positionIndex;
			evaluatedValueListForThePart.add(
				~evaluatedValueList.at(mapIndex).at(indexInMap).at(positionIndex));
		});
	});
	inputMax = 0; inputMin = 0;

	for(0, 15, {arg i;
		if((evaluatedValueListForThePart.at(i) >= inputMax),
			{inputMax = evaluatedValueListForThePart.at(i)},
			if((evaluatedValueListForThePart.at(i) <= inputMin),
				{inputMin = evaluatedValueListForThePart.at(i);}));
	});

	for(0, 15, {arg i;
		normalizedEvaluatedValueListForThePart.add(
			(evaluatedValueListForThePart.at(i) - inputMin) / (inputMax - inputMin) * (0.99 - 0.01) + 0.01);
	});

	// Send normalized value to SoundEngine
	//"Before send normalized value".postln;
	for(0, 3, {arg positionIndex;
		sendingList = List.new;
		sendingList.add("/CACIE_PA/SoundEngine/setValues");
		sendingList.add(mapIndex);
		sendingList.add(indexInMap);
		sendingList.add(positionIndex);
		sendingList.add(0);
		sendingList.add(normalizedEvaluatedValueListForThePart.at((indexInMap*4)+positionIndex));
		~soundEngineAddr.sendBundle(0.0, sendingList.asArray);
		if((normalizedEvaluatedValueListForThePart.at((indexInMap*4)+positionIndex) > 1.0),
			{"not normalized!:".post; (indexInMap*4+positionIndex).post; ":".post;
				normalizedEvaluatedValueListForThePart.at((indexInMap*4+positionIndex)).postln;});
	});
	//"After send normalized value".postln;

	// Genearte Sequence List from S-Expressions, then send both sequence list to sound engine
	for(0, 3, {arg positionIndex;
		// GenerateSequence
		convertedList = ~makeMelodyFromChromosomeString.value(~assignList.at(mapIndex).at(indexInMap), positionIndex, 4);
		// Send sequences to sound engine
		convertedList.at(0).insert(0, convertedList.at(0).size); //length of sequence
		convertedList.at(0).insert(0, 0); //degree sequence
		convertedList.at(0).insert(0, 1); //sequence
		convertedList.at(0).insert(0, positionIndex);
		convertedList.at(0).insert(0, indexInMap);
		convertedList.at(0).insert(0, mapIndex);
		convertedList.at(0).insert(0, "/CACIE_PA/SoundEngine/setValues");
		//convertedList.at(0).postln;
		//~soundEngineAddr.sendBundle(0.0, convertedList.at(0));

		convertedList.at(1).insert(0, convertedList.at(1).size); //length of sequence
		convertedList.at(1).insert(0, 1); //duration sequence
		convertedList.at(1).insert(0, 1); //sequence
		convertedList.at(1).insert(0, positionIndex);
		convertedList.at(1).insert(0, indexInMap);
		convertedList.at(1).insert(0, mapIndex);
		convertedList.at(1).insert(0, "/CACIE_PA/SoundEngine/setValues");
		//convertedList.at(1).postln;
		~soundEngineAddr.sendBundle(0.0, convertedList.at(0).asArray, convertedList.at(1).asArray);
	});


	//apply to the generateMap
	~soundEngineAddr.sendMsg("/CACIE_PA/SoundEngine/makeSequences", mapIndex, indexInMap);
};


~copyIndividual = {arg toList, indexInToList, fromList, indexInFromList;

	if((fromList.at(indexInFromList).size != 0),
		{toList.put(indexInToList, List.copyInstance(fromList.at(indexInFromList)));},
		{"~copyIndividual: fromIndividual is empty!".postln;}
	);
};

~updateVairables = {arg label, valueList;
	for(0, 3, {arg i;
		~actualVariableList.put(label, i, valueList.at(i));
	});
};

~convertVariableStringToNumber = { arg givenList, currentPosition;
	var convertedList = List.new;

	for(0, (givenList.size-1), {arg i;
		if((givenList.at(i).isKindOf(Symbol)),
			{convertedList.add(~actualVariableList.at(givenList.at(i), currentPosition));},
			{convertedList.add(givenList.at(i));}
		);
	});
	List.copyInstance(convertedList);
};

~makeMelodyFromChromosomeString = { arg chromosomeString, positionIndex, numOfBeat;
	var returnList;
	var baseChromosome;
	var counter = 0;
	var forDegree;
	var forDuration;
	var hasFunctionNode = true;

	var newList;
	var functionIndex = -1;
	var orderPattern = -1;
	var countOfFunction = 0;
	var durationArgs;
	var degreeArgs;
	var withOutSC0List = List.new;
	var numOfFunction = 0;

	baseChromosome = chromosomeString.copy;

	//Default Chromosome for Initialize ... generate [\reste, \reste] list

	//baseChromosome.postln;
	if((baseChromosome.size == 1), { //In initial Phase generate [\reste, \reste] lsit
		baseChromosome = List.new;
		baseChromosome.add(~func_plus);
		baseChromosome.add(0.01);
		baseChromosome.add(0.01);
	});
	//baseChromosome.postln;

	//change static value to -1
	//for(0, baseChromosome.size-1, {arg i;
	//	if((baseChromosome.at(i).isNumber),{baseChromosome.put(i, -1);});
	//});

	//change variable to number
	baseChromosome = ~convertVariableStringToNumber.value(baseChromosome, positionIndex);

	//Remove function node has StackCount 0
	for(0, baseChromosome.size-1, {arg i;
		if(((baseChromosome.at(i).isKindOf(Function)) &&
			(baseChromosome.at(i).value(\sCount) == 0)),
				{ },
				{withOutSC0List.add(baseChromosome.at(i));});
	});
	baseChromosome = withOutSC0List;
	//"After remove function node has StackCount 0".postln;

	//make forDegree List and forDuration List
	forDegree = List.copyInstance(baseChromosome);
	forDuration = List.new;
	baseChromosome.do({arg item, i;
		if((item.isNumber), {forDuration.add(numOfBeat);}, {forDuration.add(item);});});

	//Check numOfFunction //While is not good in sclang ...
	forDegree.do({arg node, i;
		if((node.isKindOf(Function)),{numOfFunction = numOfFunction+1;});});


	//detect processing smallest sub-tree
	counter = 0;
	while({counter < numOfFunction},{
		functionIndex = -1;
		orderPattern = -1;
		countOfFunction = 0;
		durationArgs = List.new;
		degreeArgs = List.new;

		forDegree.do({arg node, i;
			if((node.isKindOf(Function)),{
				case
				{((forDegree.at(i+1).isNumber) && (forDegree.at(i+2).isNumber))}
				{functionIndex = i; orderPattern = \NN;}
				{((forDegree.at(i+1).isNumber) && (forDegree.at(i+2).isKindOf(List)))}
				{functionIndex = i; orderPattern = \NL;}
				{((forDegree.at(i+1).isKindOf(List) && forDegree.at(i+2).isNumber))}
				{functionIndex = i; orderPattern = \LN;}
				{((forDegree.at(i+1).isKindOf(List) && forDegree.at(i+2).isKindOf(List)))}
				{functionIndex = i; orderPattern = \LL;};
			});
		});

		if((functionIndex == -1),
			{"~makeDurationAndDegreeListFromChromosomeString has no evaluating function node.".postln;});

		// make List instead of ~func_** subtree
		forDegree.removeAt(functionIndex);
		2.do({degreeArgs.add(forDegree.at(functionIndex)); forDegree.removeAt(functionIndex);});
		forDuration.removeAt(functionIndex);
		2.do({durationArgs.add(forDuration.at(functionIndex)); forDuration.removeAt(functionIndex);});

		case
		{orderPattern === \NN} {
			newList = List.new;
			durationArgs.do({arg item; newList.add(item * 0.5);});
			forDuration.insert(functionIndex, newList);

			newList = List.copyInstance(degreeArgs);
			forDegree.insert(functionIndex, newList);
		}
		{orderPattern === \NL} {
			newList = List.new;
			newList.add(durationArgs.at(0) * 0.5);
			durationArgs.at(1).do({arg item; newList.add(item * 0.5);});
			forDuration.insert(functionIndex, newList);

			newList = List.new;
			newList.add(degreeArgs.at(0));
			degreeArgs.at(1).do({arg item; newList.add(item);});
			forDegree.insert(functionIndex, newList);
		}
		{orderPattern === \LN} {
			newList = List.new;
			durationArgs.at(0).do({arg item; newList.add(item * 0.5);});
			newList.add(durationArgs.at(1) * 0.5);
			forDuration.insert(functionIndex, newList);

			newList = List.new;
			degreeArgs.at(0).do({arg item; newList.add(item);});
			newList.add(degreeArgs.at(1).copy);
			forDegree.insert(functionIndex, newList);
		}
		{orderPattern === \LL} {
			newList = List.new;
			durationArgs.do({arg currentArg; currentArg.do({arg item; newList.add(item * 0.5);});});
			forDuration.insert(functionIndex, newList);

			newList = List.new;
			degreeArgs.do({arg currentArg; currentArg.do({arg item; newList.add(item * 0.5);});});
			forDegree.insert(functionIndex, newList);
		};

		//Check Ending Condition
		//if the the top node become List, all function are removed
		//if((forDegree.at(0).isKindOf(List)), {hasFunctionNode = false;});
		if((forDegree.size == 1), {hasFunctionNode = false;});
		counter = counter + 1;
	});


	forDegree = forDegree.at(0);
	forDuration = forDuration.at(0);

	/*
	//change -1 to \rest in forDegree
	for(0, forDegree.size-1, {arg i;
		if((forDegree.at(i) < 0.1), {forDegree.put(i, \reste);});
	});
	*/

	returnList = List.new;
	returnList.add(List.copyInstance(forDegree));
	returnList.add(List.copyInstance(forDuration));
	returnList.copy;
};



//OSC receive event

~oscCopyIndividual.remove;
~oscCopyIndividual = OSCresponderNode(nil, '/CACIE_PA/GPEngine/copyIndividual', {
	arg t, r, msg;
	//"copyIndividual".postln;
	var copyField = [-1, -1];
	var boxIndex = [-1, -1];
	var fieldListObject = [-1, -1];
	var assignBox = -1;
	var arrayPos = -1;
	"toIndex : ".post; msg[1].post; " fromIndex : ".post; msg[2].postln;
	for(0, 1, {arg i;
		arrayPos = -1;
		if((msg[i+1] < 24), {copyField[i] = 0;},
			if((msg[i+1] < 26), {copyField[i] = 1; },
				if((msg[i+1] < 34), {copyField[i] = 2;},
				{copyField[i] = 3})));

		"copyField[i] : ".post; copyField[i].postln;

		switch(copyField[i],
			0, {//Assign
				arrayPos = (msg[i+1] / 4).floor;
				if((msg[i+1] < 4),{arrayPos=0;},
					if((msg[i+1] < 8), {arrayPos=1;},
						if((msg[i+1] < 12), {arrayPos = 2;},
							if((msg[i+1] < 16), {arrayPos = 3;},
								if((msg[i+1] < 20), {arrayPos = 4;},
									{arrayPos = 5;})))));

				"arrayPos: ".post; arrayPos.postln;
				switch(arrayPos,
					0, {fieldListObject[i] = ~assignList.at(0);assignBox = 0;},
					1, {fieldListObject[i] = ~assignList.at(1);assignBox = 1;},
					2, {fieldListObject[i] = ~assignList.at(2);assignBox = 2;},
					3, {fieldListObject[i] = ~assignList.at(3);assignBox = 3;},
					4, {fieldListObject[i] = ~assignList.at(4);assignBox = 4;},
					5, {fieldListObject[i] = ~assignList.at(5);assignBox = 5;}
				);
				boxIndex[i] = msg[i+1] % 4;
			},
			1, {//Copy to/from Parent Field
				fieldListObject[i] = ~parentsList;
				boxIndex[i] = (msg[i+1] - 12) % 2;
			},

			2, {//Copy to/from ChildrenList
				fieldListObject[i] = ~childrenList;
				boxIndex[i] = (msg[i+1] - 14) % 8;
			},
			3, {//Copy to/from GenomeStorage
				fieldListObject[i] = ~genomeStorageList;
				boxIndex[i] = (msg[i+1] - 22) % 8;				}
		);
	});

	//fieldListObject[0].post; " ".post; boxIndex[0].post; " ".post; fieldListObject[1].post;
	// boxIndex[1].postln;

	if((copyField[0] == 0),
		{//assign
			//"End of oscResponder".postln;
			~assignIndividualToGenerateMap.value
				(assignBox, boxIndex[0], fieldListObject[1], boxIndex[1]);
		},
		{//copy
			~copyIndividual.value
				(fieldListObject[0], boxIndex[0], fieldListObject[1], boxIndex[1]);
		}
	);

}).add;

~setValueOfVariableTerminalNode = {arg nodeLabel, positionIndex, actualValue;
	~actualVariableList.put(nodeLabel, positionIndex, actualValue);
};

~ontogeny = {
	for(0, 5, {arg mapIndex;
		for(0, 3, {arg indexInMap;
			if((~assignList.at(mapIndex).at(indexInMap) != nil), {
				~ontogenyIndividuals.value(mapIndex, indexInMap);
			});
		});
	});
};

~reproduction = {
	~reproductionMS.value(~parentsList, ~childrenList, ~functionList, ~variableList, ~staticList);
	~sendChildrenInfo.value;
};

~initChildren = {
	for(0, 7, {arg i;
		~childrenList.put(i, ~initSExpr.value(~functionList, ~variableList, ~staticList, -2, 2));
	});
	~sendChildrenInfo.value;
};

~sendChildrenInfo = {
	for(0, 7, {arg i;
		var currentChromosome = ~childrenList.at(i);
		var numOfNode = currentChromosome.size;
		var numOfFunctionNode = 0;
		var numOfTerminalNode = 0;
		//"After get currentChromosome".postln;
		for(0, numOfNode-1, {arg j;
			if((currentChromosome.at(j).value(\sCount) >= 0),
				{numOfFunctionNode = numOfFunctionNode + 1;},
				{numOfTerminalNode = numOfTerminalNode + 1;}
			);
		});

		~guiAddr.sendMsg("/CACIE_PA/GUI/childrenChromosomeInformations",
			i, numOfNode, numOfTerminalNode, numOfFunctionNode);
	});
};



/////// End of GPEngine Functions and init
)




(
~initialPhaseGPEngine.value;
~testChromosome = ~initSExpr.value(~functionList, ~variableList, ~staticList, -4, 4);
~makeMelodyFromChromosomeString.value(~testChromosome, 0, 0, 4);
)


~assignListRhythm.postln;
~parentsList.postln;
~childrenList.postln;
~genomeStorageList.postln;


(
//Test Procedure 1
~initialPhaseGPEngine.value;
//Generate Initial Populations
for(0, 7, {arg i;
	~childrenList.put(i, ~initSExpr.value(~functionList, ~variableList, ~staticList, -2, 2));
});

// Individual Copying Test
// ChildrenList To Genome Storage
for(0, 7, {arg i;
	~copyIndividual.value(~genomeStorageList, i, ~childrenList, i);
});

// Reproduction Test
for(0, 1, {arg i;
	~copyIndividual.value(~parentsList, i, ~genomeStorageList, i);
});


~reproductionMS.value(~parentsList, ~childrenList, ~functionList, ~variableList, ~staticList);

// Assign To Pattern
for(0, 3, {arg i;
	~assignIndividualToPatternMap.value(0, i, ~childrenList, i);
});

)