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
BasysRealCommunicationTests >> testClosingConnectionWhenWaitingIncomingData [
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
			
	remotePeer execute: [ :connection | connection close].
	
	5 milliSeconds wait.
]

{ #category : #tests }
BasysRealCommunicationTests >> testConnectionEstablishingOnClosedPeer [
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	remotePeer close.
	
	[remotePeer openNewConnection] should raise: BasysRemotePeerClosed
]

{ #category : #tests }
BasysRealCommunicationTests >> testConvertingPassivePeerToActive [
 
	| passivePeer activePeer secondDataWasSent firstDataWasSentLast syncSemaphore waitSemaphore |
	"producing passive peer on server"
	self connectToServerPeer openNewConnection.
	passivePeer := self waitServerSidePeer.
	passivePeer should beInstanceOf: BasysPassiveRemotePeer.	

	"producing active peer on server"
	server network: clientSideNetwork.
	activePeer := serverSideNetwork remotePeerAt: self serverAddress.
	activePeer openNewConnection.
	self waitUntil: [clientSideNetwork remotePeers size = 2].
		
	"converting existed passive peer to existed active peer"
	passivePeer becomeActiveToReplaceSamePeer: activePeer.	
	passivePeer should beInstanceOf: BasysActiveRemotePeer.
	passivePeer connectionsCount should be: 1.
	
	"now we checking that converted peer is really active and establish new connections by demand"
	syncSemaphore := Semaphore new.
	waitSemaphore := Semaphore new.
	secondDataWasSent := false.
	self fork: [	passivePeer execute: [ :connection | 
				syncSemaphore signal. waitSemaphore wait. connection sendDataPacket: 'first'.
				firstDataWasSentLast := secondDataWasSent. ]].
	syncSemaphore wait.
	passivePeer execute: [ :connection | connection sendDataPacket: 'second'.
		secondDataWasSent := true].
	waitSemaphore signal.
	self waitUntil: [secondDataWasSent & firstDataWasSentLast notNil].
	secondDataWasSent should be: true.
	firstDataWasSentLast should be: true.
	passivePeer connectionsCount should be: 2.
]

{ #category : #tests }
BasysRealCommunicationTests >> testFailedRequestAtTheEndShouldPassErrorAndNotFreeGivenConnection [
 
	| remotePeer errorCatched connection |
	remotePeer := self connectToServerPeer.
	errorCatched := false. 
	
	[
		[remotePeer execute:[:con | connection := con. 1/0 ]] 
			on: BasysCommunicationFailed do: [ :err | err defaultAction  ]
	]
		on: ZeroDivide do: [:err | errorCatched := true.
			remotePeer freeConnectionsCount should be: 0].
		
	errorCatched should be: true
]

{ #category : #tests }
BasysRealCommunicationTests >> testFailedRequestShouldAllowGetErrorWithReleasedConnection [
 
	| remotePeer errorCatched connection |
	remotePeer := self connectToServerPeer.
	errorCatched := false. 
	
	[
		[remotePeer execute:[:con | connection := con. 1/0 ]] 
			on: BasysCommunicationFailed do: [ :err | err releaseConnectionAndPassError  ]
	]
		on: ZeroDivide do: [:err | errorCatched := true.
			remotePeer freeConnectionsCount should be: 1].
		
	errorCatched should be: true
]

{ #category : #tests }
BasysRealCommunicationTests >> testFailedRequestShouldSignalSpecialCommunicationFailure [
 
	| remotePeer errorCatched connection failure |
	remotePeer := self connectToServerPeer.
	errorCatched := false. 
	
	[remotePeer execute:[:con | connection := con. 1/0 ]]
		on: BasysCommunicationFailed do: [:err | errorCatched := true.
			failure := err.
			remotePeer freeConnectionsCount should be: 0].
		
	errorCatched should be: true.
	failure reason should beInstanceOf: ZeroDivide 
	
]

{ #category : #tests }
BasysRealCommunicationTests >> testFailedRequestWhenRecursiveSpecialCommunicationFailure [
 
	| remotePeer originalFailure |
	remotePeer := self connectToServerPeer.
	originalFailure := BasysCommunicationFailed new.
	
	[remotePeer execute:[:con | originalFailure signal ]]
		should raise: originalFailure
]

{ #category : #tests }
BasysRealCommunicationTests >> testFirstConnectionEstablishing [
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	remotePeer openNewConnection.
	
	self waitServerSidePeer.
	
	serverSideNetwork connectionsCount should be: 1.
	clientSideNetwork connectionsCount should be: 1
]

{ #category : #tests }
BasysRealCommunicationTests >> testRequestFromClientToServer [
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	
	remotePeer execute: [ :connection | connection sendDataPacket: 'test data packet' ].
	
	10 milliSeconds wait.
	
	serverSideNetwork lastDataPacket should equal: 'test data packet'.

]

{ #category : #tests }
BasysRealCommunicationTests >> testRequestFromClientToServerAfterConnectionCloseHappens [
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
			
	remotePeer execute: [ :connection | connection close].	
	5 milliSeconds wait.
	
	remotePeer execute: [ :connection | connection sendDataPacket: 'server to client'].	
	5 milliSeconds wait.
	
	serverSideNetwork lastDataPacket should equal: 'server to client'
]

{ #category : #tests }
BasysRealCommunicationTests >> testRequestFromServerToClient [
 
	| remotePeer serverSideClientPeer |
	remotePeer := self connectToServerPeer.
	remotePeer openNewConnection.
	
	serverSideClientPeer := self waitServerSidePeer.
	serverSideClientPeer execute: [ :connection | connection sendDataPacket: 'server to client' ].
	
	10 milliSeconds wait.
	
	clientSideNetwork lastDataPacket should equal: 'server to client'.

]

{ #category : #tests }
BasysRealCommunicationTests >> testRequestFromServerToClientWhenNoConnectionsWasClosedByClient [
 
	| remotePeer serverSideClientPeer |
	remotePeer := self connectToServerPeer.
	remotePeer openNewConnection.
	serverSideClientPeer := self waitServerSidePeer.
	remotePeer close.
	"The pause is needed to proceed close request from client socket by server socket"
	100 milliSeconds wait. 
	
	[serverSideClientPeer execute: [ :connection | ]] should raise: OPTimedOutError.
	serverSideClientPeer connectionsCount should equal: 0
]

{ #category : #tests }
BasysRealCommunicationTests >> testRequestOnClosedActivePeer [
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	remotePeer close.
	
	[remotePeer execute:[:connection | ]] should raise: BasysRemotePeerClosed
]

{ #category : #tests }
BasysRealCommunicationTests >> testRequestOnClosedPassivePeer [
 
	| remotePeer |
	self connectToServerPeer openNewConnection.
	100 milliSeconds wait.
	remotePeer := serverSideNetwork remotePeers anyOne.
	remotePeer close.
	
	[remotePeer execute:[:connection | ]] should raise: BasysRemotePeerClosed
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
	
	remotePeer execute: [ :connection | connection sendDataPacket: 'test data packet1'.
		connection sendDataPacket: 'test data packet2'].
	
	10 milliSeconds wait.
	
	serverSideNetwork lastDataPacket should equal: 'test data packet2'
]

{ #category : #tests }
BasysRealCommunicationTests >> testTimeoutOnWaitingIncomingData [
 
	| remotePeer |
	serverSideNetwork waitingDataTimeout: 5 milliSeconds.
	remotePeer := self connectToServerPeer.
			
	remotePeer execute: [ :connection | 10 milliSeconds wait.
		connection sendDataPacket: 'test data packet' ].
	
	5 milliSeconds wait.
	
	serverSideNetwork lastDataPacket should equal: 'test data packet'.

]

{ #category : #tests }
BasysRealCommunicationTests >> testTwoParallelRequestsFromClientToServer [
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	
	self fork: [	remotePeer execute: [ :connection | 
				10 milliSeconds wait. connection sendDataPacket: 'first' ]].
	
	remotePeer execute: [ :connection | connection sendDataPacket: 'second' ].
	
	20 milliSeconds wait.

	remotePeer connectionPool numberOfAvailableObjects should be: 2
]

{ #category : #tests }
BasysRealCommunicationTests >> testTwoParallelRequestsFromServerToClient [
 
	| remotePeer serverSideClientPeer forkIsFirst |
	remotePeer := self connectToServerPeer.
	remotePeer openNewConnection.
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
]

{ #category : #tests }
BasysRealCommunicationTests >> testTwoSequentialRequestsFromClientToServer [
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	
	remotePeer execute: [ :connection | connection sendDataPacket: 'first' ].
	10 milliSeconds wait.
	remotePeer execute: [ :connection | connection sendDataPacket: 'second' ].
	
	10 milliSeconds wait.

	remotePeer connectionPool numberOfAvailableObjects should be: 1.
	serverSideNetwork lastDataPacket should equal: 'second'.
]

{ #category : #tests }
BasysRealCommunicationTests >> testWaitingConnetionByActivePeer [
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	server stop.
	
	self fork: [	remotePeer waitConnection].
	
	20 milliSeconds wait.
	server start.
	self waitLastProcessFinished.

	remotePeer connectionPool numberOfAvailableObjects should be: 1
]
