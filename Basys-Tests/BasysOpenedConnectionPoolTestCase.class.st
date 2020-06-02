Class {
	#name : #BasysOpenedConnectionPoolTestCase,
	#superclass : #BasysConnectionPoolTestCase,
	#category : #'Basys-Tests'
}

{ #category : #testing }
BasysOpenedConnectionPoolTestCase class >> isAbstract [ 	
	^self = BasysOpenedConnectionPoolTestCase 
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testClearShouldCloseAllConnections [

	| connection1 connection2 |
	connection1 := Mock new.	
	connection2 := Mock new.
	connectionPool objectToPool: connection1; objectToPool: connection2.
	
	connectionPool clear.
	
	connection1 should receive close.
	connection2 should receive close
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testClearShouldRemoveAllConnections [

	| connection1 connection2 |
	connection1 := Mock new.	
	connection2 := Mock new.
	connectionPool objectToPool: connection1; objectToPool: connection2.
	
	connectionPool clear.
	
	connectionPool should be isEmpty
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testCloseShouldCloseAllConnections [

	| connection1 connection2 |
	connection1 := Mock new.	
	connection2 := Mock new.
	connectionPool objectToPool: connection1; objectToPool: connection2.
	
	connectionPool close.
	
	connection1 should receive close.
	connection2 should receive close
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testCloseShouldConvertPoolToClosedPool [

	connectionPool close.
	
	connectionPool should beInstanceOf: BasysClosedConnectionPool 
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testCloseShouldRemoveAllConnections [

	| connection1 connection2 |
	connection1 := Mock new.	
	connection2 := Mock new.
	connectionPool objectToPool: connection1; objectToPool: connection2.
	
	connectionPool close.
	
	connectionPool should be isEmpty
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testConvertingToActivePool [

	connectionPool beActive.
	
	connectionPool should beInstanceOf: BasysActiveConnectionPool
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testConvertingToPassivePool [

	connectionPool bePassive.
	
	connectionPool should beInstanceOf: BasysPassiveConnectionPool
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testIsNotClosed [

	connectionPool should not be isClosed
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testMigrationIntoAnotherPool [

	| anotherPool connection |
	connection := Mock new.
	anotherPool := Mock new.
	connectionPool objectToPool: connection.
	
	connectionPool migrateConnectionsInto: anotherPool.
	
	anotherPool should receive objectToPool: connection.
	connectionPool numberOfAvailableObjects should be: 0
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testMigrationIntoAnotherPoolShouldBeForbiddenWhenThereIsBusyConnection [

	| connection |
	connection := Mock new.
	connectionPool objectToPool: connection.
	connectionPool borrow.
	
	[connectionPool migrateConnectionsInto: #anotherPool] should raise: BasysConnectionMigrationFailed.
	connectionPool numberOfAvailableObjects should be: 1
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testPoolingConnetionShouldSetItsRemotePeer [

	| connection |
	connection := BasysConnection new.
	
	connectionPool objectToPool: connection.
	
	connection remotePeer should be: remotePeer
]
