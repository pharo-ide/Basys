Class {
	#name : #BasysActiveConnectionPoolTests,
	#superclass : #BasysOpenedConnectionPoolTestCase,
	#category : #'Basys-Tests'
}

{ #category : #running }
BasysActiveConnectionPoolTests >> createConnectionPool [
	^BasysActiveConnectionPool of: remotePeer
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testClosesInvalidConnection [

	| invalidConnection |
	invalidConnection := connectionPool borrow.
	connectionPool return: invalidConnection.	
	invalidConnection stub isValid willReturn: false.
	
	connectionPool borrow.
	
	invalidConnection should receive close
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testCreatesNewConnectionWhenAllBusyButMoreConnectionAreAllowed [

	| connection1 connection2 |
	connection1 := connectionPool borrow.
	connection2 := connectionPool borrow.
	
	connection2 should beReturnedFrom: [ remotePeer newConnection ].
	connection1 should not be: connection2.
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testCreatesNewConnectionWhenNothingExists [

	| connection |
	connection := connectionPool borrow.
	
	connection should beReturnedFrom: [ remotePeer newConnection ].
	connectionPool numberOfActiveObjects should be: 1
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testIsActive [ 

	connectionPool should be isActive
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testIsNotPassive [ 

	connectionPool should not be isPassive
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testOpeningNewConnection [

	| newConnection |
	newConnection := Mock new.
	remotePeer stub newConnection willReturn: newConnection.
	
	connectionPool openNewConnection.
	
	newConnection should receive open.
	connectionPool numberOfAvailableObjects should be: 1.
	connectionPool should be isPooled: newConnection.
	connectionPool borrow should be: newConnection
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testOpeningNewConnectionShouldOpenItInBorrowedState [

	| newConnection |
	newConnection := Mock new.
	remotePeer stub newConnection willReturn: newConnection.
	newConnection stub open when: [ connectionPool numberOfActiveObjects ] is: 1.
	
	connectionPool openNewConnection
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testOpeningNewConnectionWhenOpenFails [

	| newConnection openError |
	newConnection := Mock new.
	remotePeer stub newConnection willReturn: newConnection.
	openError := Error new.
	newConnection stub open willRaise: openError.
	
	[connectionPool openNewConnection] should raise: openError.
	
	connectionPool numberOfAvailableObjects should be: 0
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testRaisesErrorWhenZeroConnectionsAreAllowed [

	remotePeer stub maxConnectionsCount willReturn: 0.
	
	[connectionPool borrow] should raise: BasysNoConnectionAllowed.
	
	remotePeer should not receive newConnection.
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testRemovesInvalidConnection [

	| invalidConnection newConnection |
	invalidConnection := connectionPool borrow.
	connectionPool return: invalidConnection.	
	invalidConnection stub isValid willReturn: false.
	
	newConnection := connectionPool borrow.
	newConnection should not be: invalidConnection.
	
	connectionPool numberOfActiveObjects should be: 1
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testReusesCreatedConnection [

	| reusedConnection newConnection |
	newConnection := connectionPool borrow.
	connectionPool return: newConnection.
	
	reusedConnection := connectionPool borrow.
	reusedConnection should be: newConnection
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testWaitsAnyNewIdleConnectionWhenItIsFull [
	| retrievedConnection  newConnection |
	remotePeer stub maxConnectionsCount willReturn: 1.
	connectionPool borrow.
		
	[retrievedConnection := connectionPool borrow] forkAt: Processor activePriority + 1.
	retrievedConnection should be: nil.
	
	newConnection := Mock new.
	connectionPool objectToPool: newConnection.
	retrievedConnection should be: newConnection
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testWaitsBusyConnectionToBecomeFreeWhenItIsFull [
	| busyConnection retrievedConnection  |
	remotePeer stub maxConnectionsCount willReturn: 1.
	busyConnection := connectionPool borrow.
		
	[retrievedConnection := connectionPool borrow] forkAt: Processor activePriority + 1.
	retrievedConnection should be: nil.
	
	connectionPool return: busyConnection.
	retrievedConnection should be: busyConnection
]
