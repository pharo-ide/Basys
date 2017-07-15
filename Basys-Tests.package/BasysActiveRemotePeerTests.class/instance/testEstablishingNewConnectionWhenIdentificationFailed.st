tests
testEstablishingNewConnectionWhenIdentificationFailed

	[:connection :connectionPool |
		peer connectionPool: connectionPool.
		(network stub establishNewConnectionTo: peerAddress) willReturn: connection.
		(network stub identifyLocalPeerOn: connection) willRaise: Error.
				
		[peer establishNewConnection] should fail.

		connection should receive close
	] runWithMocks 