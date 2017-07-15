tests
testRequestFromClientToServer
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	
	remotePeer execute: [ :connection | connection sendDataPacket: 'test data packet' ].
	
	10 milliSeconds wait.
	
	serverSideNetwork lastDataPacket should equal: 'test data packet'.
