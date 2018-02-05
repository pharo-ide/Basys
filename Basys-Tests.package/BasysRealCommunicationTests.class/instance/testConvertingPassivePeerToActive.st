tests
testConvertingPassivePeerToActive
 
	| passivePeer activePeer secondDataWasSent firstDataWasSentLast |
	"producing passive peer on server"
	self connectToServerPeer establishNewConnection.
	passivePeer := self waitServerSidePeer.
	passivePeer should beInstanceOf: BasysPassiveRemotePeer.	

	"producing active peer on server"
	server network: clientSideNetwork.
	activePeer := serverSideNetwork remotePeerAt: self serverAddress.
	activePeer establishNewConnection.
	self waitUntil: [clientSideNetwork remotePeers size = 2].
		
	"converting existed passive peer to existed active peer"
	passivePeer becomeActiveToReplaceSamePeer: activePeer.	
	passivePeer should beInstanceOf: BasysActiveRemotePeer.
	passivePeer connectionsCount should be: 1.
	
	"now we checking that converted peer is really active and establish new connections by demand"
	secondDataWasSent := false.
	self fork: [	passivePeer execute: [ :connection | 
				10 milliSeconds wait. connection sendDataPacket: 'first'.
				firstDataWasSentLast := secondDataWasSent. ]].
	5 milliSecond wait.
	passivePeer execute: [ :connection | connection sendDataPacket: 'second'.
		secondDataWasSent := true].
	
	self waitUntil: [secondDataWasSent & firstDataWasSentLast notNil].
	secondDataWasSent should be: true.
	firstDataWasSentLast should be: true.
	passivePeer connectionsCount should be: 2.