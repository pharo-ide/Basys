tests
testEstablishingNewConnectionWhenReceivedPeerIdIsDiffersFromExisted

	[:connection :connectionPool |
		peer connectionPool: connectionPool.
		peer id: #existedPeerId.
		(network stub establishNewConnectionTo: peerAddress) willReturn: connection.
		(network stub identifyLocalPeerOn: connection) willReturn: #differentPeerId.
	
		[peer establishNewConnection] should raise: BasysIdentificationFailed.
	
		connection should receive close.	
	] runWithMocks 