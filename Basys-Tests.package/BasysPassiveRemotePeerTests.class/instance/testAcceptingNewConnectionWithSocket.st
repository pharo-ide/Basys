tests
testAcceptingNewConnectionWithSocket

	[:connection :connectionPool |
		peer connectionPool: connectionPool.
		
		[ peer acceptNewConnectionEstablishedBy: #socket ]
			should strictly satisfy: 
		[(network createConnectionOn: #socket) willReturn: connection.
		connection remotePeer: peer.
		connectionPool objectToPool: connection.
		connectionPool fixMaxActiveObjects.
		connection acceptIncomingData].

	] runWithMocks 