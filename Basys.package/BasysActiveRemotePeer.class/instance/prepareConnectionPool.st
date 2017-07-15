initialization
prepareConnectionPool
"
	connections will be established by demand
"
	connectionPool creator: [ self establishNewConnectionWithoutPooling ].