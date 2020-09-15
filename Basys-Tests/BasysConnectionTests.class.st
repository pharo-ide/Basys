Class {
	#name : #BasysConnectionTests,
	#superclass : #TestCase,
	#instVars : [
		'connection',
		'remotePeer',
		'socket',
		'network'
	],
	#category : 'Basys-Tests'
}

{ #category : #running }
BasysConnectionTests >> setUp [
	super setUp.
	
	socket := Mock new.
	socket stub isConnected willReturn: true. "by default we are testing opened connection"
	network := Mock new.
	remotePeer := Mock new.
	
	connection := BasysConnection with: remotePeer inside: network.
	connection socket: socket.
	connection processingPriority: Processor userBackgroundPriority 
]

{ #category : #tests }
BasysConnectionTests >> testBecomeClosedWhenIncomingDataProcessIsTerminated [
	
	connection stub incomingDataLoop 
		will: [ 10 seconds asDelay wait].
	connection startIncomingDataProcess.
	connection should takeAWhile to receive incomingDataLoop.

	connection incomingDataProcess terminate.

	connection should takeAWhile to receive closeSocketSafely.
	connection incomingDataProcess should be: nil
]

{ #category : #tests }
BasysConnectionTests >> testClosing [
	
	connection stub incomingDataLoop 
		will: [ 10 seconds asDelay wait. #done].
	
	connection startIncomingDataProcess.
	connection incomingDataProcess should takeAWhile to not be: nil.
	
	connection close.
	connection should receive closeSocketSafely
]

{ #category : #tests }
BasysConnectionTests >> testClosingShouldRemoveItFromOwningPeer [
	
	connection close.
	
	remotePeer should receive removeClosedConnection: connection
]

{ #category : #tests }
BasysConnectionTests >> testClosingWhenItWasNotOpened [
	
	connection stub.
	connection incomingDataProcess should be: nil.
	
	connection close.
	
	connection should receive closeSocketSafely
]

{ #category : #tests }
BasysConnectionTests >> testGettingLocalPeerId [
	
	| id |
	id := connection localPeerId.
	
	id should beReturnedFrom: [network localPeerId]
]

{ #category : #tests }
BasysConnectionTests >> testGettingRemotePeerId [
	
	| id |
	id := connection remotePeerId.
	
	id should beReturnedFrom: [remotePeer id]
]

{ #category : #tests }
BasysConnectionTests >> testHasProcessingPriorityFromNetworkByDefault [

	connection processingPriority: nil.
	
	connection processingPriority should beReturnedFrom: [ network processingPriority ]
]

{ #category : #tests }
BasysConnectionTests >> testIsIdentified [
	
	| result |
	result := connection isIdentified.
	
	result should beReturnedFrom: [remotePeer isIdentified]
]

{ #category : #tests }
BasysConnectionTests >> testIsOpenedWhenSocketIsConnected [
	
	connection socket: nil.
	connection should not be isOpened.
	
	connection socket: Mock new.
	connection should be isOpened
]

{ #category : #tests }
BasysConnectionTests >> testIsValid [
	
	socket := Mock new.
	connection socket: socket.
	
	connection isValid should beReturnedFrom: [ socket isConnected ]
]

{ #category : #tests }
BasysConnectionTests >> testIsValidWhenNotOpenedYet [
	
	connection socket: nil.
	connection should not be isOpened.
	
	connection should be isValid
]

{ #category : #tests }
BasysConnectionTests >> testOpeningShouldAssignSocket [
	
	remotePeer stub address willReturn: #peerAddress.

	connection open.
	
	connection socket should beReturnedFrom: [
		network openNewConnectionTo: #peerAddress]
]

{ #category : #tests }
BasysConnectionTests >> testOpeningShouldCloseConnectionWhenIdentificationFails [
	
	| error |
	connection stub.
	error := Error new.
	(network stub identifyLocalPeerOn: connection) willRaise: error.
	
	[connection open] should raise: error.
	connection should receive close
	
]

{ #category : #tests }
BasysConnectionTests >> testOpeningShouldCloseConnectionWhenReceivedPeerIdIsWrong [
	
	| error |
	connection stub.
	error := Error new.
	(remotePeer stub ensureIdentity: Any) willRaise: error.
	
	[connection open] should raise: error.
	connection should receive close
	
]

{ #category : #tests }
BasysConnectionTests >> testOpeningShouldEnsurePeerIdentityWithReceivedValue [
	
	(network stub identifyLocalPeerOn: connection) willReturn: #remotePeerId.
	
	connection open.
	
	remotePeer should receive ensureIdentity: #remotePeerId
]

{ #category : #tests }
BasysConnectionTests >> testOpeningShouldStartIncompingDataProcessBeforeIdentification [
	
	connection stub.
	
	connection open.
	
	[connection startIncomingDataProcess.
	network identifyLocalPeerOn: connection] should beDoneInOrder
]

{ #category : #tests }
BasysConnectionTests >> testProcessingIncomingObject [
	
	(network stub receiveObjectBy: connection) willReturn: #receivedObject.
	
	connection processIncomingObject.
	
	network should takeAWhile to receive process: #receivedObject receivedFrom: remotePeer
]

{ #category : #tests }
BasysConnectionTests >> testProcessingIncomingObjectShouldBeAsync [
	
	connection processIncomingObject.
	
	(network should takeAWhile to receive process: Any receivedFrom: remotePeer)
		inAnotherProcess
]

{ #category : #tests }
BasysConnectionTests >> testProcessingIncomingObjectShouldBeDoneWithProcessingPriority [
	
	connection processIncomingObject.
	
	(network should takeAWhile to receive process: Any receivedFrom: remotePeer) 
		inProcessWhich 	priority should be: connection processingPriority
]

{ #category : #tests }
BasysConnectionTests >> testSendingObject [
	
	connection sendObject: #object.
	
	network should receive sendObject: #object by: connection
]

{ #category : #tests }
BasysConnectionTests >> testSendingObjectWhenConnectionIsNotOpened [
	
	connection stub isOpened willReturn: false.
	
	connection sendObject: #object.
	
	connection should receive open
]

{ #category : #tests }
BasysConnectionTests >> testStartingIncomingDataProcess [
	
	connection stub incomingDataLoop will: [ 10 seconds wait ].
	
	connection startIncomingDataProcess.
	
	connection should takeAWhile to receive incomingDataLoop 
		inProcessWhich should be: connection incomingDataProcess
]
