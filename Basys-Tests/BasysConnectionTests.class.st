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
	connection socket: socket
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
	connection should receive closeSocketSafely.
]

{ #category : #tests }
BasysConnectionTests >> testClosingWhenItWasNotOpened [
	
	connection stub.
	connection incomingDataProcess should be: nil.
	
	connection close.
	
	connection should receive closeSocketSafely
]

{ #category : #tests }
BasysConnectionTests >> testHasProcessingPriorityByDefault [
	
	connection processingPriority should be: Processor userBackgroundPriority
]

{ #category : #tests }
BasysConnectionTests >> testIsNotOpenedWhenNoSocketIsAssigned [
	
	connection socket: nil.
	
	connection should not be isOpened
]

{ #category : #tests }
BasysConnectionTests >> testIsOpenedWhenSocketIsConnected [
	
	connection isOpened should beReturnedFrom: [socket isConnected] 
]

{ #category : #tests }
BasysConnectionTests >> testOpeningShouldAssignSocket [
	
	remotePeer stub address willReturn: #peerAddress.

	connection open.
	
	connection socket should beReturnedFrom: [
		network establishNewConnectionTo: #peerAddress]
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
BasysConnectionTests >> testProcessingIncomingDataPacket [
	
	(network stub receiveIncomingDataPacketFrom: remotePeer by: connection) willReturn: #dataPacket.
	
	connection processIncomingDataPacket.
	
	network should takeAWhile to receive process: #dataPacket receivedFrom: remotePeer
]

{ #category : #tests }
BasysConnectionTests >> testProcessingIncomingDataPacketShouldBeAsync [
	
	connection processIncomingDataPacket.
	
	(network should takeAWhile to receive process: Any receivedFrom: remotePeer)
		inAnotherProcess
]

{ #category : #tests }
BasysConnectionTests >> testProcessingIncomingDataPacketShouldDoneWithProcessingPriority [
	
	connection processIncomingDataPacket.
	
	(network should takeAWhile to receive process: Any receivedFrom: remotePeer) 
		inProcessWhich 	priority should be: connection processingPriority
]

{ #category : #tests }
BasysConnectionTests >> testProcessingWrongProtocolError [
	
	(network stub receiveIncomingDataPacketFrom: remotePeer by: connection) 
				willRaise: BasysWrongProtocolError.
				
	connection incomingDataLoop.
	
	socket should receive closeAndDestroy
]

{ #category : #tests }
BasysConnectionTests >> testSendingDataPacket [
	
	connection sendDataPacket: #dataPacket.
	
	network should receive sendDataPacket: #dataPacket by: connection
]

{ #category : #tests }
BasysConnectionTests >> testSendingDataPacketWhenConnectionIsNotOpened [
	
	connection stub isOpened willReturn: false.
	
	connection sendDataPacket: #dataPacket.
	
	connection should receive open
]

{ #category : #tests }
BasysConnectionTests >> testStartingIncomingDataProcess [
	
	connection stub incomingDataLoop will: [ 10 seconds wait ].
	
	connection startIncomingDataProcess.
	
	connection should takeAWhile to receive incomingDataLoop 
		inProcessWhich should be: connection incomingDataProcess
]
