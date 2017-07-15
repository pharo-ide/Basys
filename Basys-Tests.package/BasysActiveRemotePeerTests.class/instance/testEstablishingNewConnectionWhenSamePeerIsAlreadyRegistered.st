tests
testEstablishingNewConnectionWhenSamePeerIsAlreadyRegistered

	[:connection :connectionPool :existedPeer |
		peer connectionPool: connectionPool.
		
		[ peer establishNewConnection]
			should strictly satisfy: 
		[(network establishNewConnectionTo: peerAddress) willReturn: connection.
		connection remotePeer: peer.
		connection acceptIncomingData.
		(network identifyLocalPeerOn: connection) willReturn: #remotePeerId.
		(network remotePeerWithId: #remotePeerId ifAbsent: Any) willReturn: existedPeer.
		existedPeer addNewConnection: connection.
		existedPeer becomeActiveToReplaceSamePeer: peer.
		connectionPool objectToPool: connection].
	
		peer id should be: nil.
	] runWithMocks 