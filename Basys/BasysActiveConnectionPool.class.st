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

{ #category : #private }
BasysActiveConnectionPool >> unsafeBorrow [
	remotePeer maxConnectionsCount > 0 ifFalse: [ BasysNoConnectionAllowed signal ].
	
	^self critical: [ 
		self waitUntil: [
			self numberOfIdleObjects > 0 
				or: [self numberOfActiveObjects < remotePeer maxConnectionsCount ]].
		super unsafeBorrow 
	].
]
