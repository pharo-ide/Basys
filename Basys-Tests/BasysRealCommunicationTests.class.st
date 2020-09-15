Class {
	#name : #BasysRealCommunicationTests,
	#superclass : #BasysRealCommunicationTestCase,
	#category : 'Basys-Tests'
}

{ #category : #running }
BasysRealCommunicationTests >> networkClass [
	^BasysNetworkExample
]

{ #category : #tests }
BasysRealCommunicationTests >> testClosingConnectionImmediatelyAfterOpen [
 
	| clientSidePeer |
	clientSidePeer := self connectToServerPeer.		
	clientSidePeer connectToLocalPeerFor: [ :connection | connection open; close ].

	clientSidePeer where connectionCount should be: 0.	
	serverSideNetwork where connectionCount should takeAWhile to be: 0.
]

{ #category : #tests }
BasysRealCommunicationTests >> testClosingConnectionWhenRemoteSideWaitsIncomingData [
 
	| clientSidePeer |
	clientSidePeer := self connectToServerPeer.		
	clientSidePeer connectToLocalPeerFor: [ :connection | 
		connection open. 
		10 milliSeconds wait.
		connection close ].

	clientSidePeer where connectionCount should be: 0.
	serverSideNetwork where connectionCount should takeAWhile to be: 0.
]

{ #category : #tests }
BasysRealCommunicationTests >> testClosingPeerConnections [
 
	| clientSidePeer |
	clientSidePeer := self connectToServerPeer.
	clientSidePeer openNewConnection.
	
	self waitServerSidePeer.
	
	clientSidePeer closeConnections.
	
	clientSideNetwork connectionCount should be: 0
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
	"Now connection will follow identification procedure.
	It will detect an existing passive peer with same id
	and it will convert this activePeer to it"
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
BasysRealCommunicationTests >> testOpeningNewConnectionWhenClientSidePeerDoesNotAllowMoreConnections [

	| clientSidePeer |
	clientSidePeer := self connectToServerPeer.
	clientSidePeer openNewConnection.		
	clientSidePeer maxConnections: 1.
	
	[clientSidePeer openNewConnection] should raise: BasysTooManyConnections.

	clientSideNetwork connectionCount should be: 1
]

{ #category : #tests }
BasysRealCommunicationTests >> testOpeningNewConnectionWhenServerDoesNotAllowThemAtAll [
 
	| clientSidePeer |
	serverSideNetwork maxConnectionsPerPeer: 0.
	
	clientSidePeer := self connectToServerPeer.
	clientSidePeer openNewConnection.	
	30 milliSeconds wait.
	
	serverSideNetwork connectionCount should be: 0	.
	serverSideNetwork remotePeers should haveSize: 0
]

{ #category : #tests }
BasysRealCommunicationTests >> testOpeningNewConnectionWhenServerSidePeerDoesNotAllowMoreConnections [
 
	| clientSidePeer serverSidePeer |
	clientSidePeer := self connectToServerPeer.
	clientSidePeer openNewConnection.		
	serverSidePeer := self waitServerSidePeer.
	serverSidePeer maxConnections: 1.
	
	clientSidePeer openNewConnection.
	30 milliSeconds wait.
	
	serverSideNetwork connectionCount should be: 1.
	serverSideNetwork remotePeers should equal: { serverSidePeer }
]

{ #category : #tests }
BasysRealCommunicationTests >> testRequestFromClientToServer [
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	
	remotePeer connectToLocalPeerFor: [ :connection | connection sendObject: 'test string' ].
	
	10 milliSeconds wait.
	
	serverSideNetwork lastReceivedString should equal: 'test string'

]

{ #category : #tests }
BasysRealCommunicationTests >> testRequestFromClientToServerAfterConnectionCloseHappens [
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
			
	remotePeer connectToLocalPeerFor: [ :connection | connection open; close].	
	5 milliSeconds wait.
	
	remotePeer connectToLocalPeerFor: [ :connection | connection sendObject: 'server to client'].	
	5 milliSeconds wait.
	
	serverSideNetwork lastReceivedString should equal: 'server to client'
]

{ #category : #tests }
BasysRealCommunicationTests >> testRequestFromServerToClient [
 
	| remotePeer serverSidePeer |
	remotePeer := self connectToServerPeer.
	remotePeer openNewConnection.
	
	serverSidePeer := self waitServerSidePeer.
	serverSidePeer connectToLocalPeerFor: [ :connection | connection sendObject: 'server to client' ].
	
	10 milliSeconds wait.
	
	clientSideNetwork lastReceivedString should equal: 'server to client'.

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
	
	[serverSidePeer connectToLocalPeerFor: [ :connection | ]] should raise: BasysNoConnection.
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
BasysRealCommunicationTests >> testSendingSingleObject [
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	
	remotePeer sendObject: 'test string'.
	
	10 milliSeconds wait.
	
	serverSideNetwork lastReceivedString should equal: 'test string'.

]

{ #category : #tests }
BasysRealCommunicationTests >> testSendingTwoObjectsImmediately [
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	
	remotePeer connectToLocalPeerFor: [ :connection | 
		connection sendObject: 'test string1'.
		connection sendObject: 'test string2'].
	
	10 milliSeconds wait.
	
	serverSideNetwork lastReceivedString should equal: 'test string2'
]

{ #category : #tests }
BasysRealCommunicationTests >> testTimeoutOnWaitingIncomingObject [
 
	| remotePeer |
	serverSideNetwork waitingDataTimeout: 5 milliSeconds.
	remotePeer := self connectToServerPeer.
			
	remotePeer connectToLocalPeerFor: [ :connection | 10 milliSeconds wait.
		connection sendObject: 'test string' ].
	
	5 milliSeconds wait.
	
	serverSideNetwork lastReceivedString should equal: 'test string'.

]

{ #category : #tests }
BasysRealCommunicationTests >> testTwoParallelRequestsFromClientToServer [
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	
	self fork: [	remotePeer connectToLocalPeerFor: [ :connection | 
				10 milliSeconds wait. connection sendObject: 'first' ]].
	
	remotePeer connectToLocalPeerFor: [ :connection | connection sendObject: 'second' ].
	
	remotePeer where connectionCount should takeAWhile to be: 2
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
			 connection sendObject: 'server to client' ]].
	
	self passForkedProcesses.
	
	serverSidePeer connectToLocalPeerFor: [ :connection | 
		forkIsFirst ifNil: [ forkIsFirst := false].
			 connection sendObject: 'server to client'].
		
	[ forkIsFirst ] should takeAWhile to be: true
]

{ #category : #tests }
BasysRealCommunicationTests >> testTwoSequentialRequestsFromClientToServer [
 
	| remotePeer |
	remotePeer := self connectToServerPeer.
	
	remotePeer connectToLocalPeerFor: [ :connection | connection sendObject: 'first' ].
	10 milliSeconds wait.
	remotePeer connectToLocalPeerFor: [ :connection | connection sendObject: 'second' ].
	
	10 milliSeconds wait.

	remotePeer connectionCount should be: 1.
	serverSideNetwork lastReceivedString should equal: 'second'.
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
