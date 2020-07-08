Class {
	#name : #BasysPassiveRemotePeerTests,
	#superclass : #BasysRemotePeerTestCase,
	#category : 'Basys-Tests'
}

{ #category : #running }
BasysPassiveRemotePeerTests >> peerClass [ 
	^BasysRemotePeer 
]

{ #category : #running }
BasysPassiveRemotePeerTests >> setUp [
	super setUp.
	peer stub isConnected willReturn: true
]

{ #category : #tests }
BasysPassiveRemotePeerTests >> testAddingNewOpenedConnection [

	| connection pool |
	connection := Mock new.
	pool := Mock new.
	peer connectionPool: pool.
	peer stub newConnection willReturn: connection.
	
	peer addNewConnectionOpenedRemotelyUsing: #socket.

	[ connection socket: #socket.
	pool objectToPool: connection.
	connection startIncomingDataProcess  ] should beDoneInOrder 
]
