Class {
	#name : #BasysPassiveConnectionPool,
	#superclass : #BasysConnectionPool,
	#category : #Basys
}

{ #category : #testing }
BasysPassiveConnectionPool >> isActive [
	^false
]

{ #category : #'object-lifecycle' }
BasysPassiveConnectionPool >> makeObject [
	"Passive connection pool should never attempt to create connection by itself"
	self error: 'should not happen'
]

{ #category : #private }
BasysPassiveConnectionPool >> objectToPool: aBasysConnection [
	remotePeer maxConnectionsCount = 0 ifTrue: [ 
		BasysNoConnectionAllowed signal ].
	self numberOfAvailableObjects >= remotePeer maxConnectionsCount ifTrue: [ 
			^ BasysTooManyConnections signal ].
		
	^super objectToPool: aBasysConnection
]

{ #category : #private }
BasysPassiveConnectionPool >> unsafeBorrow [
		
	^self critical: [ 
		self numberOfAvailableObjects = 0 ifTrue: [  BasysConnectionDoesNotExist signal ].
		
		self waitUntil: [ self numberOfIdleObjects > 0 ].
		super unsafeBorrow 
	].
]
