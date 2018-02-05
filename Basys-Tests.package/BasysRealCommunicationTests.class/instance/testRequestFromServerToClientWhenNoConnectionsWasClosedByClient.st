tests
testRequestFromServerToClientWhenNoConnectionsWasClosedByClient
 
	| remotePeer serverSideClientPeer |
	remotePeer := self connectToServerPeer.
	remotePeer establishNewConnection.
	serverSideClientPeer := self waitServerSidePeer.
	remotePeer close.
	"The pause is needed to proceed close request from client socket by server socket"
	100 milliSeconds wait. 
	
	[serverSideClientPeer execute: [ :connection | ]] should raise: OPTimedOutError.
	serverSideClientPeer connectionsCount should equal: 0