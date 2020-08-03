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
BasysActiveConnectionPoolTests >> testCreatesNewConnectionWhenNothingExists [

	| connection |
	connection := connectionPool allocateConnection.
	
	connection should beReturnedFrom: [ remotePeer newConnection ].
	connectionPool should haveSize: 1
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

	connectionPool openNewConnection.
	
	connectionPool should haveSize: 1.
	remotePeer should receive newConnection
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testOpeningNewConnectionLeftItFree [

	| newConnection |
	newConnection := Mock new.
	remotePeer stub newConnection willReturn: newConnection.
	
	connectionPool openNewConnection.
	
	[newConnection open.
	newConnection beFree] should beDoneInOrder.
	
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testOpeningNewConnectionShouldOpenItInBusyState [

	| newConnection |
	newConnection := Mock new.
	remotePeer stub newConnection willReturn: newConnection.
	
	connectionPool openNewConnection.
	
	[newConnection beBusy.
	newConnection open] should beDoneInOrder.
	
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testOpeningNewConnectionWhenOpenFails [

	| newConnection openError |
	newConnection := Mock new.
	remotePeer stub newConnection willReturn: newConnection.
	openError := Error new.
	newConnection stub open willRaise: openError.
	
	[connectionPool openNewConnection] should raise: openError.
	
	connectionPool should be isEmpty
]
