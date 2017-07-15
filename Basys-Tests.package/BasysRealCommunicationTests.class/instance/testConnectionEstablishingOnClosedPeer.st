tests
testConnectionEstablishingOnClosedPeer
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	remotePeer close.
	
	[remotePeer establishNewConnection] should raise: BasysRemotePeerClosed