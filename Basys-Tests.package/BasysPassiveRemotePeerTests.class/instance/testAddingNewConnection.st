tests
testAddingNewConnection

	[:connection :connectionPool |
		peer connectionPool: connectionPool.
		
		[ peer addNewConnection: connection ]
			should strictly satisfy: 
		[connection remotePeer: peer.
		connectionPool objectToPool: connection.
		connectionPool fixMaxActiveObjects].

	] runWithMocks 