communication
establishNewConnection

	| connection |
	connection := self establishNewConnectionWithoutPooling.
	connectionPool objectToPool: connection