Class {
	#name : #BasysClosedConnectionPoolTests,
	#superclass : #BasysConnectionPoolTestCase,
	#category : #'Basys-Tests'
}

{ #category : #running }
BasysClosedConnectionPoolTests >> createConnectionPool [
	^BasysClosedConnectionPool of: remotePeer
]

{ #category : #tests }
BasysClosedConnectionPoolTests >> testFailsToBeConvertedToActivePeer [

	[connectionPool beActive] should raise: BasysRemotePeerClosed 
]

{ #category : #tests }
BasysClosedConnectionPoolTests >> testFailsToBeConvertedToPassivePeer [

	[connectionPool bePassive] should raise: BasysRemotePeerClosed 
]

{ #category : #tests }
BasysClosedConnectionPoolTests >> testFailsToBorrowNewConnection [

	[connectionPool borrow] should raise: BasysRemotePeerClosed 
]

{ #category : #tests }
BasysClosedConnectionPoolTests >> testFailsToOpenNewConnection [

	[connectionPool openNewConnection] should raise: BasysRemotePeerClosed 
]

{ #category : #tests }
BasysClosedConnectionPoolTests >> testFailsToPoolIncomingConnection [

	[connectionPool objectToPool: #newConnection] should raise: BasysRemotePeerClosed 
]

{ #category : #tests }
BasysClosedConnectionPoolTests >> testIsClosed [

	connectionPool should be isClosed
]

{ #category : #tests }
BasysClosedConnectionPoolTests >> testIsNotActive [ 

	connectionPool should not be isActive 
]

{ #category : #tests }
BasysClosedConnectionPoolTests >> testIsNotPassive [ 

	connectionPool should not be isPassive
]
