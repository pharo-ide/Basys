tests
testClosingConnectionWhenWaitingIncomingData
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
			
	remotePeer execute: [ :connection | connection close].
	
	5 milliSeconds wait.