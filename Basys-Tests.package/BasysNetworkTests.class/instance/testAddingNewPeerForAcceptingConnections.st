tests
testAddingNewPeerForAcceptingConnections

	| remotePeer |
	
	remotePeer := network addNewPeerForAcceptingConnections.
	
	remotePeer should beInstanceOf: BasysPassiveRemotePeer.
	remotePeer network should be: network.
	network remotePeers should include: remotePeer