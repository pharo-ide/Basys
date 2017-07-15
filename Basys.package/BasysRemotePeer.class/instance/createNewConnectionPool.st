initialization
createNewConnectionPool

	connectionPool := OPBasicPool new.
	connectionPool maxWaitForBorrow: 45. "milliSeconds"
	connectionPool validator: [ :c | c isValid ].
	connectionPool destroyer: [ :connection | connection close ].

	self prepareConnectionPool
