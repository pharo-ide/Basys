tests
testTwoParallelRequestsFromClientToServer
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	
	self fork: [	remotePeer execute: [ :connection | 
				10 milliSeconds wait. connection sendDataPacket: 'first' ]].
	
	remotePeer execute: [ :connection | connection sendDataPacket: 'second' ].
	
	20 milliSeconds wait.

	remotePeer connectionPool numberOfAvailableObjects should be: 2