controlling
becomeActiveToReplaceSamePeer: aBasysActivePeer

	address := aBasysActivePeer address.
	network removeRemotePeer: aBasysActivePeer.
	self primitiveChangeClassTo: aBasysActivePeer.
	self prepareConnectionPool.
	connectionPool maxActiveObjects: nil.
	
	aBasysActivePeer becomeForward: self