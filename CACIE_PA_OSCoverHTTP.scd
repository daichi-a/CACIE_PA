(
	~oscFromPHPServer = NetAddr("localhost", 57120);
	~oscFromPHP.remove;
	~oscFromPHP = OSCresponderNode(nil, '/test', {arg t, r, msg;
		"Receive /test OSC Message".postln;
		msg.postln;
	}).add;
)