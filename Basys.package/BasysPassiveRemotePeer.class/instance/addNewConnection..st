private
addNewConnection: aBasysConnection

	aBasysConnection remotePeer: self.
	
	connectionPool objectToPool: aBasysConnection.
	connectionPool fixMaxActiveObjects