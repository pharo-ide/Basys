Class {
	#name : #BasysPassiveRemotePeerTests,
	#superclass : #BasysRemotePeerTestCase,
	#category : 'Basys-Tests'
}

{ #category : #running }
BasysPassiveRemotePeerTests >> peerClass [ 
	^BasysPassiveRemotePeer 
]

{ #category : #running }
BasysPassiveRemotePeerTests >> setUp [
	super setUp.
	peer stub isConnected willReturn: true
]

{ #category : #tests }
BasysPassiveRemotePeerTests >> testAcceptingNewConnectionWithSocket [

	[:connection :connectionPool |
		peer connectionPool: connectionPool.
		
		[ peer acceptNewConnectionEstablishedBy: #socket ]
			should strictly satisfy: 
		[(network createConnectionOn: #socket) willReturn: connection.
		connection remotePeer: peer.
		connectionPool objectToPool: connection.
		connectionPool fixMaxActiveObjects.
		connection acceptIncomingData].

	] runWithMocks 
]

{ #category : #tests }
BasysPassiveRemotePeerTests >> testAddingNewConnection [

	[:connection :connectionPool |
		peer connectionPool: connectionPool.
		
		[ peer addNewConnection: connection ]
			should strictly satisfy: 
		[connection remotePeer: peer.
		connectionPool objectToPool: connection.
		connectionPool fixMaxActiveObjects].

	] runWithMocks 
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

{ #category : #tests }
BasysPassiveRemotePeerTests >> testIdentificationWhenThereIsNoSameRegisteredPeer [

	[				
		[ (peer beIdentifiedAs: #peerId) should be: peer]
			should strictly satisfy: 
		[ (network remotePeerWithId: #peerId ifAbsent: Any)
				will: [ :arg1 :arg2 | arg2 value ] ].

		peer id should be: #peerId
	] runWithMocks 
]

{ #category : #tests }
BasysPassiveRemotePeerTests >> testIdentificationWhenThereIsRegisteredPeerWithGivenId [

	[:registeredPeer :existedConnectionPool |			
		peer connectionPool: existedConnectionPool.
		[ (peer beIdentifiedAs: #peerId) should be: registeredPeer]
			should strictly satisfy: 
		[ (network remotePeerWithId: #peerId ifAbsent: Any) willReturn: registeredPeer.
		registeredPeer importConnectionsFrom: existedConnectionPool.
		network removeRemotePeer: peer].
		peer should be: registeredPeer.
		
	] runWithMocks 
]
