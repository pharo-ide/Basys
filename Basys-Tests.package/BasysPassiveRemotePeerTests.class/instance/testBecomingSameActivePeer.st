tests
testBecomingSameActivePeer

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