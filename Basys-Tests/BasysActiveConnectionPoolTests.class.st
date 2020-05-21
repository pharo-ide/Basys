Class {
	#name : #BasysActiveConnectionPoolTests,
	#superclass : #BasysConnectionPoolTestCase,
	#category : #'Basys-Tests'
}

{ #category : #running }
BasysActiveConnectionPoolTests >> createConnectionPool [
	^BasysActiveConnectionPool of: remotePeer
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testCreatesNewConnectionWhenNothingExists [

	| actual |
	actual := connectionPool borrow.
	
	actual should beReturnedFrom: [ remotePeer newConnection ]
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testRaisesErrorWhenZeroConnectionsAreAllowed [

	remotePeer stub maxConnectionsCount willReturn: 0.
	
	[connectionPool borrow] should raise: BasysNoConnectionAllowed.
	
	remotePeer should not receive newConnection.
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testReusesCreatedConnection [

	| actual created |
	created := connectionPool borrow.
	connectionPool return: created.
	
	actual := connectionPool borrow.
	actual should be: created
]

{ #category : #tests }
BasysActiveConnectionPoolTests >> testWaitsForFreeConnectionWhenAllConnectionsAreCreated [
	| busyConnection freeConnection  |
	remotePeer stub maxConnectionsCount willReturn: 1.
	busyConnection := connectionPool borrow.
		
	[freeConnection := connectionPool borrow] forkAt: Processor activePriority + 1.
	freeConnection should be: nil.
	
	connectionPool return: busyConnection.
	freeConnection should be: busyConnection
]
