tests
testIdentificationWhenThereIsRegisteredPeerWithGivenId

	[:registeredPeer :existedConnectionPool |			
		peer connectionPool: existedConnectionPool.
		[ (peer beIdentifiedAs: #peerId) should be: registeredPeer]
			should strictly satisfy: 
		[ (network remotePeerWithId: #peerId ifAbsent: Any) willReturn: registeredPeer.
		registeredPeer importConnectionsFrom: existedConnectionPool.
		network removeRemotePeer: peer].
		peer should be: registeredPeer.
		
	] runWithMocks 