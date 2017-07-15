tests
testImportingConnectionsFromSomeConnectionPool

	[:connectionPool :anotherConnectionPool :eachConnection |		
		peer connectionPool: connectionPool.
		[ peer importConnectionsFrom: anotherConnectionPool]
			should strictly satisfy: 
		[(anotherConnectionPool migrateObjectsInto: connectionPool andDo: Any) will: [ :arg1 :arg2 | arg2 value: eachConnection ].
		eachConnection remotePeer: peer ].

	] runWithMocks 