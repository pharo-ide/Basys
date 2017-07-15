tests
testSendingSingleDataPacketShortcut
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	
	remotePeer sendDataPacket: 'test data packet'.
	
	10 milliSeconds wait.
	
	serverSideNetwork lastDataPacket should equal: 'test data packet'.
