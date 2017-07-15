initialization
prepareConnectionPool
"
	no connections by default
"
	connectionPool maxActiveObjects: 0.
	connectionPool destroyer: [ :connection | 
		connectionPool fixMaxActiveObjects.
		connection close].