tests
testTwoParallelRequestsFromServerToClient
 
	| remotePeer serverSideClientPeer forkIsFirst |
	remotePeer := self connectToServerPeer.
	remotePeer establishNewConnection.
	serverSideClientPeer := serverSideNetwork remotePeers anyOne.
	forkIsFirst := nil.
	
	self fork: [serverSideClientPeer execute: [ :connection | 
			10 milliSeconds wait. forkIsFirst ifNil: [forkIsFirst := true].
			 connection sendDataPacket: 'server to client' ]].
	
	2 milliSeconds wait.
	
	serverSideClientPeer execute: [ :connection | 
		forkIsFirst ifNil: [ forkIsFirst := false].
			 connection sendDataPacket: 'server to client'].
		
	10 milliSeconds wait.
	forkIsFirst should be: true.