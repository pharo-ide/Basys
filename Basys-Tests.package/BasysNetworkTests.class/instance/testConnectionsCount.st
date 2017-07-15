tests
testConnectionsCount

	| remotePeer1 remotePeer2 |
	remotePeer1 := Mock new.
	remotePeer1 stub connectionsCount willReturn: 2.
	remotePeer2 := Mock new.
	remotePeer2 stub connectionsCount willReturn: 5.
	
	network addRemotePeer: remotePeer1; addRemotePeer: remotePeer2.
		
	network connectionsCount should be: 7