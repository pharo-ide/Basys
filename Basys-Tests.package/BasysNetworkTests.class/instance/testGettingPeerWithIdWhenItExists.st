tests
testGettingPeerWithIdWhenItExists

	| remotePeer actual |
	remotePeer := BasysPassiveRemotePeer new id: 1.
	network addRemotePeer: remotePeer.
	
	actual := network remotePeerWithId: 1 ifAbsent: [  ].
	
	actual should be: remotePeer