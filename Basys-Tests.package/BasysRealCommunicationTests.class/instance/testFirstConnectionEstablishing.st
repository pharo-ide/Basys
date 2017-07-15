tests
testFirstConnectionEstablishing
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	remotePeer establishNewConnection.
	
	10 milliSeconds wait.
	
	serverSideNetwork connectionsCount should be: 1.
	clientSideNetwork connectionsCount should be: 1