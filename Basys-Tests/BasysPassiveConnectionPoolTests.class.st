Class {
	#name : #BasysPassiveConnectionPoolTests,
	#superclass : #BasysConnectionPoolTestCase,
	#category : #'Basys-Tests'
}

{ #category : #running }
BasysPassiveConnectionPoolTests >> createConnectionPool [
	^BasysPassiveConnectionPool of: remotePeer
]

{ #category : #tests }
BasysPassiveConnectionPoolTests >> testRaisesErrorWhenAllAvailableConnectionsAreInvalid [

	| invalidConnection |
	invalidConnection := Mock new.
	connectionPool objectToPool: invalidConnection.
	invalidConnection stub isValid willReturn: false.
	
	[connectionPool borrow] should raise: BasysConnectionDoesNotExist
]

{ #category : #tests }
BasysPassiveConnectionPoolTests >> testRaisesErrorWhenConnectionWasRequestedButNothingExists [

	[connectionPool borrow] should raise: BasysConnectionDoesNotExist
]

{ #category : #tests }
BasysPassiveConnectionPoolTests >> testRaisesErrorWhenTooManyConnectionsAlreadyExist [

	| connection connection2 |
	connection := Mock new.
	connection2 := Mock new.
	remotePeer stub maxConnectionsCount willReturn: 1.
	
	connectionPool objectToPool: connection.
	[connectionPool objectToPool: connection2] should raise: BasysTooManyConnections
]

{ #category : #tests }
BasysPassiveConnectionPoolTests >> testRaisesErrorWhenZeroConnectionsAreAllowed [

	| connection |
	connection := Mock new.
	remotePeer stub maxConnectionsCount willReturn: 0.
	
	[connectionPool objectToPool: connection] should raise: BasysNoConnectionAllowed
]

{ #category : #tests }
BasysPassiveConnectionPoolTests >> testRemovesAndClosesInvalidConnection [

	| invalidConnection |
	invalidConnection := Mock new.
	connectionPool objectToPool: invalidConnection.
	invalidConnection stub isValid willReturn: false.
	
	[connectionPool borrow] should raise: BasysConnectionDoesNotExist.

	connectionPool numberOfAvailableObjects should be: 0.
	invalidConnection should receive close
]

{ #category : #tests }
BasysPassiveConnectionPoolTests >> testReturnsValidConnection [

	| invalidConnection validConnection retrievedConnection  |
	invalidConnection := Mock new.
	validConnection := Mock new.
	connectionPool objectToPool: invalidConnection; objectToPool: validConnection.
	invalidConnection stub isValid willReturn: false.
	
	retrievedConnection := connectionPool borrow.
	
	retrievedConnection should be: validConnection
]

{ #category : #tests }
BasysPassiveConnectionPoolTests >> testReusesPooledConnection [

	| reusedConnection connection |
	connection := Mock new.
	connectionPool objectToPool: connection.
	
	reusedConnection := connectionPool borrow.
	reusedConnection should be: connection
]

{ #category : #tests }
BasysPassiveConnectionPoolTests >> testWaitsAnyNewIdleConnectionWhenOthersAreBusy [
	| retrievedConnection  newConnection busyConnection |
	busyConnection := Mock new.
	connectionPool objectToPool: busyConnection.
	connectionPool borrow should be: busyConnection.
		
	[retrievedConnection := connectionPool borrow] forkAt: Processor activePriority + 1.
	retrievedConnection should be: nil.
	
	newConnection := Mock new.
	connectionPool objectToPool: newConnection.
	retrievedConnection should be: newConnection
]

{ #category : #tests }
BasysPassiveConnectionPoolTests >> testWaitsBusyConnectionToBecomeFreeWhenNoFreeIsAvailable [
	| busyConnection retrievedConnection  |
	remotePeer stub maxConnectionsCount willReturn: 1.
	busyConnection := Mock new.
	connectionPool objectToPool: busyConnection.
	connectionPool borrow should be: busyConnection.
		
	[retrievedConnection := connectionPool borrow] forkAt: Processor activePriority + 1.
	retrievedConnection should be: nil.
	
	connectionPool return: busyConnection.
	retrievedConnection should be: busyConnection
]

{ #category : #tests }
BasysPassiveConnectionPoolTests >> testWaitsValidConnectionWhenFreeWasInvalid [
	| busyConnection retrievedConnection  invalidConnection |
	busyConnection := Mock new.
	connectionPool objectToPool: busyConnection.
	connectionPool borrow should be: busyConnection.
	invalidConnection := Mock new.
	connectionPool objectToPool: invalidConnection.
	connectionPool numberOfAvailableObjects should be: 2.
	
	invalidConnection stub isValid willReturn: false.		
	[retrievedConnection := connectionPool borrow] forkAt: Processor activePriority + 1.
	retrievedConnection should be: nil.
	connectionPool numberOfAvailableObjects should be: 1.
	
	connectionPool return: busyConnection.
	retrievedConnection should be: busyConnection
]
