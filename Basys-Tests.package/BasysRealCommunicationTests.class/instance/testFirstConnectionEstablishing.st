tests
testFirstConnectionEstablishing
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	remotePeer establishNewConnection.
	
	self waitServerSidePeer.
	
	serverSideNetwork connectionsCount should be: 1.
	clientSideNetwork connectionsCount should be: 1