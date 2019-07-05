"
I represent closed remote peer which is not allow any network communication.
Any interaction with me will raise BasysRemotePeerClosed error.

When active or passive peers become closed they change class to me to forbid any possible remote communication
"
Class {
	#name : #BasysClosedRemotePeer,
	#superclass : #BasysRemotePeer,
	#category : 'Basys'
}

{ #category : #communication }
BasysClosedRemotePeer >> establishNewConnection [

	^BasysRemotePeerClosed signal
]

{ #category : #testing }
BasysClosedRemotePeer >> isClosed [

	^true
]

{ #category : #initialization }
BasysClosedRemotePeer >> prepareConnectionPool [
"
	connections can't be established
"
	connectionPool creator: [ BasysRemotePeerClosed signal ].
	"it is hook to immediatelly raise error by creator.
	With maxActiveObjects=0 pool will be waiting for new conection from outside"
	connectionPool maxActiveObjects: Float infinity
]
