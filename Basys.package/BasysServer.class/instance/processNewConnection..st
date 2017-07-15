controlling
processNewConnection: clientSocket

	| newPeer |
	newPeer := network addNewPeerForAcceptingConnections.
	
	newPeer acceptNewConnectionEstablishedBy: clientSocket