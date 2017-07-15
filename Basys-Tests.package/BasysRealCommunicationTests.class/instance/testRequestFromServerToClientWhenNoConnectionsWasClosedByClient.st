tests
testRequestFromServerToClientWhenNoConnectionsWasClosedByClient
 
	| remotePeer serverSideClientPeer |
	remotePeer := self connectToServerPeer.
	remotePeer establishNewConnection.
	remotePeer close.
	
	serverSideClientPeer := serverSideNetwork remotePeers anyOne.
	40 milliSeconds wait.
	
	[serverSideClientPeer execute: [ :connection | ]] should raise: OPTimedOutError.
	serverSideClientPeer connectionsCount should equal: 0