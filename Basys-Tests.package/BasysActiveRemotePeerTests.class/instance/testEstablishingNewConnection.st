tests
testEstablishingNewConnection

	[:connection :connectionPool |
		peer connectionPool: connectionPool.
		
		[ peer establishNewConnection]
			should strictly satisfy: 
		[(network establishNewConnectionTo: peerAddress) willReturn: connection.
		connection remotePeer: peer.
		connection acceptIncomingData.
		(network identifyLocalPeerOn: connection) willReturn: #remotePeerId.
		(network remotePeerWithId: #remotePeerId ifAbsent: Any) will: [:arg1 :arg2 | arg2 value].
		connectionPool objectToPool: connection].
	
		peer id should be: #remotePeerId.
	] runWithMocks 