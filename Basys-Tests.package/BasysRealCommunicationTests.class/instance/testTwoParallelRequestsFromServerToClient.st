tests
testTwoParallelRequestsFromServerToClient
 
	| remotePeer serverSideClientPeer forkIsFirst |
	remotePeer := self connectToServerPeer.
	remotePeer establishNewConnection.
	serverSideClientPeer := self waitServerSidePeer.
	forkIsFirst := nil.
	
	self fork: [serverSideClientPeer execute: [ :connection | 
			10 milliSeconds wait. forkIsFirst ifNil: [forkIsFirst := true].
			 connection sendDataPacket: 'server to client' ]].
	
	self passForkedProcesses.
	
	serverSideClientPeer execute: [ :connection | 
		forkIsFirst ifNil: [ forkIsFirst := false].
			 connection sendDataPacket: 'server to client'].
		
	self waitUntil: [ forkIsFirst notNil ].
	forkIsFirst should be: true.