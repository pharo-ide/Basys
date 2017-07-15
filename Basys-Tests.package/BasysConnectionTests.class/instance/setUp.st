running
setUp
	super setUp.
	
	socket := Mock new.
	network := Mock new.
	remotePeer := Mock new.
	
	connection := BasysConnection inside: network on: socket.
	connection remotePeer: remotePeer