tests
testRequestFromServerToClient
 
	| remotePeer serverSideClientPeer |
	remotePeer := self connectToServerPeer.
	remotePeer establishNewConnection.
	
	serverSideClientPeer := self waitServerSidePeer.
	serverSideClientPeer execute: [ :connection | connection sendDataPacket: 'server to client' ].
	
	10 milliSeconds wait.
	
	clientSideNetwork lastDataPacket should equal: 'server to client'.
