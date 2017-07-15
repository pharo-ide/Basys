tests
testClosingConnections

	[:peer1 :peer2 |
		network addRemotePeer: peer1; addRemotePeer: peer2.
		
		network closeConnections.
		
		peer1 should receive closeConnections.
		peer2 should receive closeConnections
			
	] runWithMocks 