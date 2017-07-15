accessing
addNewPeerForAcceptingConnections

	| newPeer |
	newPeer := BasysPassiveRemotePeer inside: self.
	remotePeers add: newPeer.
	^newPeer