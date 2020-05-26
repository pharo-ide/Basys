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

{ #category : #testing }
BasysClosedRemotePeer >> isClosed [

	^true
]

{ #category : #communication }
BasysClosedRemotePeer >> openNewConnection [

	^BasysRemotePeerClosed signal
]
