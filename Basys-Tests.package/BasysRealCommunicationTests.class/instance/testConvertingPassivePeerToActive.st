tests
testConvertingPassivePeerToActive
 
	| passivePeer activePeer secondDataWasSent firstDataWasSentLast |
	"producing passive peer on server"
	self connectToServerPeer establishNewConnection.
	
	"producing active peer on server"
	server network: clientSideNetwork.
	activePeer := serverSideNetwork remotePeerAt: self serverAddress.
	activePeer establishNewConnection.
	
	passivePeer := serverSideNetwork remotePeers anyOne.
	passivePeer should beInstanceOf: BasysPassiveRemotePeer.	
		
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
	
	20 milliSeconds wait.	
	secondDataWasSent should be: true.
	firstDataWasSentLast should be: true.
	passivePeer connectionsCount should be: 2.