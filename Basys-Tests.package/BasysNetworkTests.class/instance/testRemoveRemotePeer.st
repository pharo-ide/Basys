tests
testRemoveRemotePeer

	network addRemotePeer: #remotePeer.
	
	network removeRemotePeer: #remotePeer.
	
	network remotePeers should not include: #remotePeer