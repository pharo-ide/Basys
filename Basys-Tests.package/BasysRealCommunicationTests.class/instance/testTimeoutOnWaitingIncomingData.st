tests
testTimeoutOnWaitingIncomingData
 
	| remotePeer |
	serverSideNetwork waitingDataTimeout: 5 milliSeconds.
	remotePeer := self connectToServerPeer.
			
	remotePeer execute: [ :connection | 10 milliSeconds wait.
		connection sendDataPacket: 'test data packet' ].
	
	5 milliSeconds wait.
	
	serverSideNetwork lastDataPacket should equal: 'test data packet'.
