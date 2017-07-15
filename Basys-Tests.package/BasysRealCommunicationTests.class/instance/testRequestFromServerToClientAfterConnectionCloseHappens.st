tests
testRequestFromServerToClientAfterConnectionCloseHappens
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
			
	remotePeer execute: [ :connection | connection close].	
	5 milliSeconds wait.
	
	remotePeer execute: [ :connection | connection sendDataPacket: 'server to client'].	
	5 milliSeconds wait.
	
	serverSideNetwork lastDataPacket should equal: 'server to client'