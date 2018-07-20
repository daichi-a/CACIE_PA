(

~gpEngineAddr = NetAddr("localhost", 57120);
~soundEngineAddr = NetAddr("localhost", 57120);
~guiAddr =  NetAddr("localhost", 12000);
~scoreAddr = NetAddr("192.168.0.3", 12001);
~externalEffectsAddr = NetAddr("localhost", 12002);
~internalEffectsAddr = NetAddr("localhost", 12003);
~textureSoundAddr = NetAddr("localhost", 12004);


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
~oscPhotoMusicInitEngine = OSCresponderNode(nil, '/CACIE_PA/PhotoMusic/Controller/init/GPEngine', {
	~initialPhaseGPEngine.value;
	~initPhotoMusicGP.value;
}).add; 

~oscPhotoMusicInitChildren.remove;
~oscPhotoMusicInitChildren = OSCresponderNode(nil, '/CACIE_PA/PhotoMusic/Controller/init/children', {
	~initChildren.value;
}).add;

~oscPhotoMusicReproduction.remove;
~oscPhotoMusicReproduction = OSCresponderNode(nil, '/CACIE_PA/PhotoMusic/Controller/reproduction', {
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
	for(0, 5, {arg i; for(0, 3, {arg j; ~soundEngineAddr.sendBundle(0.0, ["/CACIE_PA/SoundEngine/makeSequences", i, j]);});});
}).add;

)

~evalSExpr.value(~initSExpr.value(~functionList, ~variableList, ~staticList, -4, 4).postln).postln;
