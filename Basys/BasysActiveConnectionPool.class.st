Class {
	#name : #BasysActiveConnectionPool,
	#superclass : #BasysConnectionPool,
	#category : #Basys
}

{ #category : #testing }
BasysActiveConnectionPool >> isActive [ 
	^true
]

{ #category : #'object-lifecycle' }
BasysActiveConnectionPool >> makeObject [
	^remotePeer newConnection
]

{ #category : #communication }
BasysActiveConnectionPool >> openNewConnection [
	"This method forcibly opens new connection and pools it in opened state.
	It allows to avoid lazy connection opening and perform the slow open logic in required time.
	Also it is useful for testing of #open logic without sending any real data for processing"
	| newConnection |
	newConnection := self makeObject.
	self critical: [ 
		self allowNewConnection.
		borrowedObjects add: newConnection].
	[newConnection open] ifCurtailed: [ 
		"In case of failed open operation we do not need to keep this connection"
		self critical: [ borrowedObjects remove: newConnection ].
	].
	self return: newConnection
]

{ #category : #private }
BasysActiveConnectionPool >> unsafeBorrow [
	remotePeer maxConnections > 0 ifFalse: [ BasysNoConnectionAllowed signal ].
	
	^self critical: [ 
		self waitUntil: [
			self numberOfIdleObjects > 0 
				or: [self numberOfActiveObjects < remotePeer maxConnections ]].
		super unsafeBorrow 
	].
]
