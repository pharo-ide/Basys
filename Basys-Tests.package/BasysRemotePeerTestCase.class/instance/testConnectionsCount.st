tests
testConnectionsCount

	peer connectionPool objectToPool: #connection1.
	peer connectionPool objectToPool: #connection2.	 
	
	peer connectionsCount should be: 2