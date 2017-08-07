tests
testWaitingConnetionByActivePeer
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	server stop.
	
	self fork: [	remotePeer waitConnection].
	
	20 milliSeconds wait.
	server start.
	self waitLastProcessFinished.

	remotePeer connectionPool numberOfAvailableObjects should be: 1