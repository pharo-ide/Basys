"
I am special kind of pool which is able to establish new connections with remote peer.

I open new connections by demand when no connection exists or when all connections are busy (if more connections are allowed).

In addition I provide suitable method #openNewConnection to forcibly create and open new connection.
It allows to avoid lazy connection opening and perform the slow open logic in required time.
Also it is useful for testing of #open logic without sending any real data for processing
"
Class {
	#name : #BasysActiveConnectionPool,
	#superclass : #BasysConnectionPool,
	#category : #Basys
}

{ #category : #testing }
BasysActiveConnectionPool >> isActive [ 
	^true
]

{ #category : #private }
BasysActiveConnectionPool >> nextFreeConnectionOrNil [ 
	^super nextFreeConnectionOrNil ifNil: [ 
		connections size < remotePeer maxConnections ifTrue: [ self addNewConnection ]		
	]
]

{ #category : #controlling }
BasysActiveConnectionPool >> openNewConnection [
	"This method forcibly opens new connection and pools it in opened state.
	It allows to avoid lazy connection opening and perform the slow open logic in required time.
	Also it is useful for testing of #open logic without sending any real data for processing"
	| newConnection |
	self guardAccessDuring: [ 
		self allowNewConnection.
		newConnection := self addNewConnection.
		newConnection beBusy].
	 
	[newConnection open.
	self guardAccessDuring: [ newConnection beFree]
	] ifCurtailed: [ 
		"In case of failed open operation we do not need to keep this connection"
		newConnection close.		
		self guardAccessDuring: [ connections remove: newConnection ]
	]
]
