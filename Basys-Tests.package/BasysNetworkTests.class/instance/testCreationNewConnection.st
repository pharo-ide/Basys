tests
testCreationNewConnection
	
	| actual |
	actual := network createConnectionOn: #socket.
	
	actual should beInstanceOf: BasysConnection.
	actual network should be: network.
	actual socket should be: #socket