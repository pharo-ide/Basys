controlling
importConnectionsFrom: anotherConnectionsPool

	anotherConnectionsPool migrateObjectsInto: connectionPool andDo: [ :each | each remotePeer: self ]