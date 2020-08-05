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
BasysActiveConnectionPoolTests >> testAllowsToWaitOpenedConnectionWhenItFailsWithTimeout [
	| connection done syncSemaphore |
	syncSemaphore := Semaphore new.
	connection := Mock new.
	connectionPool addConnection: connection.
	connection stub beOpened will: [ syncSemaphore wait. ConnectionTimedOut signal].
	done := false.
	[connectionPool waitOpenedConnection. done := true] forkAt: Processor activePriority + 1.
	done should be: false.
	syncSemaphore signal.
	done should be: false.
	connection stub beOpened will: [ syncSemaphore wait ].
	syncSemaphore signal; signal. "first signal continue first block with timeout"
	done should be: true.
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testCreatesNewConnectionWhenAllBusyButMoreConnectionsAreAllowed [

	| busyConnection newConnection |
	busyConnection := Mock new.
	connectionPool addConnection: busyConnection.
	busyConnection stub isBusy willReturn: true.
	newConnection := connectionPool allocateConnection.
	
	newConnection should beReturnedFrom: [ remotePeer newConnection ].
	newConnection should not be: busyConnection.
	connectionPool should haveSize: 2
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testCreatesNewConnectionWhenItNeedsToOpenNewOne [

	connectionPool openNewConnection.
	
	connectionPool should haveSize: 1.
	remotePeer should receive newConnection
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testCreatesNewConnectionWhenItNeedsToWaitOpenedOneButNothingExists [
	| connection |
	connection := Mock new.
	remotePeer stub newConnection willReturn: connection.

	[connectionPool waitOpenedConnection] forkAt: Processor activePriority + 1.

	connection should receive beOpened.
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testCreatesNewConnectionWhenNothingExists [

	| connection |
	connection := connectionPool allocateConnection.
	
	connection should beReturnedFrom: [ remotePeer newConnection ].
	connectionPool should haveSize: 1
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testDoesNotKeepNewOpenedConnectionWhenOpenFails [

	| newConnection openError |
	newConnection := Mock new.
	remotePeer stub newConnection willReturn: newConnection.
	openError := Error new.
	newConnection stub open willRaise: openError.
	
	[connectionPool openNewConnection] should raise: openError.
	
	connectionPool should be isEmpty
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
BasysActiveConnectionPoolTests >> testLeavesNewOpenedConnectionInFreeState [

	| newConnection |
	newConnection := Mock new.
	remotePeer stub newConnection willReturn: newConnection.
	
	connectionPool openNewConnection.
	
	[newConnection open.
	newConnection beFree] should beDoneInOrder.
	
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testOpensNewConnectionInBusyState [

	| newConnection |
	newConnection := Mock new.
	remotePeer stub newConnection willReturn: newConnection.
	
	connectionPool openNewConnection.
	
	[newConnection beBusy.
	newConnection open] should beDoneInOrder.
	
]
