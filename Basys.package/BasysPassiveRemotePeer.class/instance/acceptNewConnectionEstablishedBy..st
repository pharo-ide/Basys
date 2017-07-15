communication
acceptNewConnectionEstablishedBy: aSocket

	| connection |
	connection := network createConnectionOn: aSocket.
	
	self addNewConnection: connection.
	
	connection acceptIncomingData