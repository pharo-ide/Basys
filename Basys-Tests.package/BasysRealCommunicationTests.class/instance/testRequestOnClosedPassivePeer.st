tests
testRequestOnClosedPassivePeer
 
	| remotePeer |
	self connectToServerPeer establishNewConnection.
	100 milliSeconds wait.
	remotePeer := serverSideNetwork remotePeers anyOne.
	remotePeer close.
	
	[remotePeer execute:[:connection | ]] should raise: BasysRemotePeerClosed