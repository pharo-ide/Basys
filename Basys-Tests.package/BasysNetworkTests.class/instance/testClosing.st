tests
testClosing

	[:peer1 :peer2 |
		network addRemotePeer: peer1; addRemotePeer: peer2.
		
		network close.
		
		peer1 should receive close.
		peer2 should receive close.
		network remotePeers should be isEmpty	
			
	] runWithMocks 