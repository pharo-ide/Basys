tests
testTwoSequentialRequestsFromClientToServer
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	
	remotePeer execute: [ :connection | connection sendDataPacket: 'first' ].
	10 milliSeconds wait.
	remotePeer execute: [ :connection | connection sendDataPacket: 'second' ].
	
	10 milliSeconds wait.

	remotePeer connectionPool numberOfAvailableObjects should be: 1.
	serverSideNetwork lastDataPacket should equal: 'second'.