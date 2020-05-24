Class {
	#name : #BasysPassiveConnectionPool,
	#superclass : #BasysConnectionPool,
	#category : #Basys
}

{ #category : #'object-lifecycle' }
BasysPassiveConnectionPool >> makeObject [
	"Passive connection pool should never attempt to create connection by itself"
	self error: 'should not happen'
]

{ #category : #private }
BasysPassiveConnectionPool >> objectToPool: anObject [
	remotePeer maxConnectionsCount = 0 ifTrue: [ 
		BasysNoConnectionAllowed signal ].
	self numberOfAvailableObjects >= remotePeer maxConnectionsCount ifTrue: [ 
			^ BasysTooManyConnections signal ].
		
	^super objectToPool: anObject
]

{ #category : #private }
BasysPassiveConnectionPool >> unsafeBorrow [
	self numberOfAvailableObjects = 0 ifTrue: [  BasysConnectionDoesNotExist signal ].
	
	^self critical: [ 
		self waitUntil: [
			self numberOfIdleObjects > 0 ].
		super unsafeBorrow 
	].
]
