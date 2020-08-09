Class {
	#name : #BasysRealCommunicationTests,
	#superclass : #BasysRealCommunicationTestCase,
	#category : 'Basys-Tests'
}

{ #category : #running }
BasysRealCommunicationTests >> networkClass [
	^BasysNetworkStub
]

{ #category : #tests }
BasysRealCommunicationTests >> testClosingConnectionWhenRemoteSideWaitsIncomingData [
 
	| clientSidePeer serverSidePeer |
	clientSidePeer := self connectToServerPeer.		
	clientSidePeer connectToLocalPeerFor: [ :connection | connection open; close].

	clientSidePeer connectionCount should be: 0.
	serverSidePeer := self serverSidePeer.
	serverSidePeer connectionCount should be: 0
]

{ #category : #tests }
BasysRealCommunicationTests >> testConnectionEstablishingOnClosedPeer [
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	remotePeer close.
	
	[remotePeer openNewConnection] should raise: MessageNotUnderstood 
]

{ #category : #tests }
BasysRealCommunicationTests >> testConvertingPassivePeerToActive [
 
	| passivePeer activePeer |
	"producing passive peer on server"
	self connectToServerPeer openNewConnection.
	passivePeer := self waitServerSidePeer.
	passivePeer should be isPassive.	

	"producing active peer on server"
	server network: clientSideNetwork.
	activePeer := serverSideNetwork remotePeerAt: self serverAddress.
	activePeer openNewConnection.
	20 milliSeconds wait.
	clientSideNetwork remotePeers should haveSize: 1.
	
	activePeer should be: passivePeer.
	passivePeer connectionCount should be: 2.
	
	"now we are checking that converted peer is really active and can open new connections"
	passivePeer openNewConnection.
	passivePeer connectionCount should be: 3
]

{ #category : #tests }
BasysRealCommunicationTests >> testFailedRequestShouldPassErrorAndFreeConnection [
 
	| remotePeer errorCatched |
	remotePeer := self connectToServerPeer.
	errorCatched := false. 
	
	[remotePeer connectToLocalPeerFor:[:con | con. 1/0 ]]
		on: ZeroDivide do: [:err | errorCatched := true.
			remotePeer freeConnectionCount should be: 1].
		
	errorCatched should be: true
]

{ #category : #tests }
BasysRealCommunicationTests >> testFirstConnectionOpening [
 
	| clientSidePeer |
	clientSidePeer := self connectToServerPeer.
	clientSidePeer openNewConnection.
	
	self waitServerSidePeer.
	
	clientSideNetwork connectionCount should be: 1.
	clientSidePeer id should equal: server port.
	serverSideNetwork connectionCount should be: 1.
	self serverSidePeer id should equal: server port
	
]

{ #category : #tests }
BasysRealCommunicationTests >> testRequestFromClientToServer [
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	
	remotePeer connectToLocalPeerFor: [ :connection | connection sendDataPacket: 'test data packet' ].
	
	10 milliSeconds wait.
	
	serverSideNetwork lastDataPacket should equal: 'test data packet'.

]

{ #category : #tests }
BasysRealCommunicationTests >> testRequestFromClientToServerAfterConnectionCloseHappens [
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
			
	remotePeer connectToLocalPeerFor: [ :connection | connection open; close].	
	5 milliSeconds wait.
	
	remotePeer connectToLocalPeerFor: [ :connection | connection sendDataPacket: 'server to client'].	
	5 milliSeconds wait.
	
	serverSideNetwork lastDataPacket should equal: 'server to client'
]

{ #category : #tests }
BasysRealCommunicationTests >> testRequestFromServerToClient [
 
	| remotePeer serverSidePeer |
	remotePeer := self connectToServerPeer.
	remotePeer openNewConnection.
	
	serverSidePeer := self waitServerSidePeer.
	serverSidePeer connectToLocalPeerFor: [ :connection | connection sendDataPacket: 'server to client' ].
	
	10 milliSeconds wait.
	
	clientSideNetwork lastDataPacket should equal: 'server to client'.

]

{ #category : #tests }
BasysRealCommunicationTests >> testRequestFromServerToClientWhenAllConnectionsWereClosedByClient [
 
	| clientSidePeer serverSidePeer |
	clientSidePeer := self connectToServerPeer.
	clientSidePeer openNewConnection.
	serverSidePeer := self waitServerSidePeer.
	clientSidePeer close.
	"The pause is needed to proceed close request from client socket by server socket"
	100 milliSeconds wait. 
	
	[serverSidePeer connectToLocalPeerFor: [ :connection | ]] should raise: BasysConnectionDoesNotExist.
	serverSidePeer connectionCount should equal: 0
]

{ #category : #tests }
BasysRealCommunicationTests >> testRequestOnClosedActivePeer [
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	remotePeer close.
	
	[remotePeer connectToLocalPeerFor:[:connection | ]] should raise: BasysRemotePeerClosed
]

{ #category : #tests }
BasysRealCommunicationTests >> testRequestOnClosedPassivePeer [
 
	| serverSidePeer |
	self connectToServerPeer openNewConnection.
	serverSidePeer := self waitServerSidePeer.
	serverSidePeer close.
	
	[serverSidePeer connectToLocalPeerFor:[:connection | ]] should raise: BasysRemotePeerClosed
]

{ #category : #tests }
BasysRealCommunicationTests >> testSendingSingleDataPacketShortcut [
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	
	remotePeer sendDataPacket: 'test data packet'.
	
	10 milliSeconds wait.
	
	serverSideNetwork lastDataPacket should equal: 'test data packet'.

]

{ #category : #tests }
BasysRealCommunicationTests >> testSendingTwoDataPacketImmediately [
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	
	remotePeer connectToLocalPeerFor: [ :connection | connection sendDataPacket: 'test data packet1'.
		connection sendDataPacket: 'test data packet2'].
	
	10 milliSeconds wait.
	
	serverSideNetwork lastDataPacket should equal: 'test data packet2'
]

{ #category : #tests }
BasysRealCommunicationTests >> testTimeoutOnWaitingIncomingData [
 
	| remotePeer |
	serverSideNetwork waitingDataTimeout: 5 milliSeconds.
	remotePeer := self connectToServerPeer.
			
	remotePeer connectToLocalPeerFor: [ :connection | 10 milliSeconds wait.
		connection sendDataPacket: 'test data packet' ].
	
	5 milliSeconds wait.
	
	serverSideNetwork lastDataPacket should equal: 'test data packet'.

]

{ #category : #tests }
BasysRealCommunicationTests >> testTwoParallelRequestsFromClientToServer [
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	
	self fork: [	remotePeer connectToLocalPeerFor: [ :connection | 
				10 milliSeconds wait. connection sendDataPacket: 'first' ]].
	
	remotePeer connectToLocalPeerFor: [ :connection | connection sendDataPacket: 'second' ].
	
	20 milliSeconds wait.

	remotePeer connectionCount should be: 2
]

{ #category : #tests }
BasysRealCommunicationTests >> testTwoParallelRequestsFromServerToClient [
 
	| clientSidePeer serverSidePeer forkIsFirst |
	clientSidePeer := self connectToServerPeer.
	clientSidePeer openNewConnection.
	serverSidePeer := self waitServerSidePeer.
	forkIsFirst := nil.
	
	self fork: [serverSidePeer connectToLocalPeerFor: [ :connection | 
			10 milliSeconds wait. forkIsFirst ifNil: [forkIsFirst := true].
			 connection sendDataPacket: 'server to client' ]].
	
	self passForkedProcesses.
	
	serverSidePeer connectToLocalPeerFor: [ :connection | 
		forkIsFirst ifNil: [ forkIsFirst := false].
			 connection sendDataPacket: 'server to client'].
		
	[ forkIsFirst ] should takeAWhile to be: true
]

{ #category : #tests }
BasysRealCommunicationTests >> testTwoSequentialRequestsFromClientToServer [
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	
	remotePeer connectToLocalPeerFor: [ :connection | connection sendDataPacket: 'first' ].
	10 milliSeconds wait.
	remotePeer connectToLocalPeerFor: [ :connection | connection sendDataPacket: 'second' ].
	
	10 milliSeconds wait.

	remotePeer connectionCount should be: 1.
	serverSideNetwork lastDataPacket should equal: 'second'.
]

{ #category : #tests }
BasysRealCommunicationTests >> testWaitingConnetionByActivePeer [
	| remotePeer |
	remotePeer := self connectToServerPeer.
	server stop.
	
	self fork: [ remotePeer waitConnection ].	
	20 milliSeconds wait.
	remotePeer connectionCount should equal: 0.
		
	server start.
	self waitLastProcessFinished.

	remotePeer connectionCount should equal: 1
]

{ #category : #tests }
BasysRealCommunicationTests >> testWaitingConnetionByPassivePeer [
	| remotePeer done serverSideRemotePeer |
	remotePeer := self connectToServerPeer.
	remotePeer openNewConnection.
	20 milliSeconds wait.
	done := false.
	serverSideRemotePeer := self serverSidePeer.
	serverSideRemotePeer closeConnections.
	self fork: [ serverSideRemotePeer waitConnection. done := true ].	
	20 milliSeconds wait.
	done should be: false.
		
	remotePeer openNewConnection.
	self waitLastProcessFinished.
	done should be: true.

	remotePeer connectionCount should equal: 1
]
