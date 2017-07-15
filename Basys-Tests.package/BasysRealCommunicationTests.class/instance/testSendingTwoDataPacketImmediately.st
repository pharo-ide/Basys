tests
testSendingTwoDataPacketImmediately
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	
	remotePeer execute: [ :connection | connection sendDataPacket: 'test data packet1'.
		connection sendDataPacket: 'test data packet2'].
	
	10 milliSeconds wait.
	
	serverSideNetwork lastDataPacket should equal: 'test data packet2'