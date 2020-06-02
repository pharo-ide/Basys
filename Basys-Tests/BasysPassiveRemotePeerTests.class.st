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

{ #category : #tests }
BasysPassiveRemotePeerTests >> testBecomingSameActivePeer [

	| activePeer |
	[:existedConnections |
		activePeer := BasysActiveRemotePeer new.	
		activePeer address: #newAddress.
		peer connectionPool: existedConnections.
		[peer becomeActiveToReplaceSamePeer: activePeer.]
			should strictly satisfy: 
		[ network removeRemotePeer: activePeer.
		existedConnections creator: (Instance of: BlockClosure).
		existedConnections maxActiveObjects: nil].

		peer should beInstanceOf: BasysActiveRemotePeer.
		peer address should be: #newAddress.
		peer connectionPool should be: existedConnections.
		activePeer should be: peer.
	] runWithMocks 
]

{ #category : #tests }
BasysPassiveRemotePeerTests >> testHasZeroMaxActiveConnectionsByDefault [

	peer connectionPool maxActiveObjects should be: 0
]
