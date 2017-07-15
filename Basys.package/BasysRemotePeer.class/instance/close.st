controlling
close
	"Here we really close peer. It will be converted to BasysClosedRemotePeer 
	which forbid any remote communication. Also we remove this peer from network".
	
	connectionPool creator: [ BasysRemotePeerClosed signal ].
	
	BasysClosedRemotePeer adoptInstance: self.	
	self closeConnections.	
	network removeRemotePeer: self.
	
	"it is hook to immediatelly raise error by creator.
	With maxActiveObjects=0 pool will be waiting for new connection from outside and then it will fail by timeout error. But we want more precise failure"	
	connectionPool maxActiveObjects: Float infinity.