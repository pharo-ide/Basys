tests
testRequestOnClosedActivePeer
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	remotePeer close.
	
	[remotePeer execute:[:connection | ]] should raise: BasysRemotePeerClosed