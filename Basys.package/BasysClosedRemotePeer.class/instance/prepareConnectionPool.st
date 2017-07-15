initialization
prepareConnectionPool
"
	connections can't be established
"
	connectionPool creator: [ BasysRemotePeerClosed signal ].
	"it is hook to immediatelly raise error by creator.
	With maxActiveObjects=0 pool will be waiting for new conection from outside"
	connectionPool maxActiveObjects: Float infinity