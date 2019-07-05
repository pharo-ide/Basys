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
	network := Mock new.
	remotePeer := Mock new.
	
	connection := BasysConnection inside: network on: socket.
	connection remotePeer: remotePeer
]

{ #category : #tests }
BasysConnectionTests >> testClosing [
	
	connection stub incomingDataLoop 
		will: [ 10 seconds asDelay wait. #done].
	
	connection acceptIncomingData.
	20 milliSecond wait.
	connection close.
	20 milliSecond wait.

	connection incomingDataProcess should be isTerminated.
	connection should receive closeSocketSafely.
]

{ #category : #tests }
BasysConnectionTests >> testHasProcessingPriorityByDefault [
	
	connection processingPriority should be: Processor userBackgroundPriority
]

{ #category : #tests }
BasysConnectionTests >> testProcessingIncomingDataPacket [
	
	[:process |
		[ connection processIncomingDataPacket ]
			should strictly satisfy: 
		[ (network receiveIncomingDataPacketFrom: remotePeer by: connection) willReturn: #dataPacket.
		(remotePeer prepareProcessingOf: #dataPacket) willReturn: process.
		process run ]

	] runWithMocks 
]

{ #category : #tests }
BasysConnectionTests >> testProcessingWrongProtocolError [
	
	[
		[ connection incomingDataLoop ]
			should strictly satisfy: 
		[ (network receiveIncomingDataPacketFrom: remotePeer by: connection) 
				willRaise: BasysWrongProtocolError.
		socket closeAndDestroy]

	] runWithMocks 
]

{ #category : #tests }
BasysConnectionTests >> testSendingDataPacket [
	
	[
		[ connection sendDataPacket: #dataPacket ]
			should strictly satisfy: 
		[ network sendDataPacket: #dataPacket by: connection ]

	] runWithMocks 
]

{ #category : #tests }
BasysConnectionTests >> testStartingIncomingDataProcess [
	
	connection stub incomingDataLoop 
		shouldBeSentInAnotherProcess;
		will: [ 
			Processor activeProcess should be: connection incomingDataProcess.
			Processor activeProcess terminate ].
	
	connection acceptIncomingData.
	20 milliSecond wait.
	
	connection incomingDataProcess should be isTerminated
]

{ #category : #tests }
BasysConnectionTests >> testTerminatedIncomingDataProcessShouldCloseSocket [
	
	connection stub incomingDataLoop 
		will: [ 10 seconds asDelay wait. #done].
	
	connection acceptIncomingData.
	20 milliSecond wait.
	connection incomingDataProcess terminate.

	connection should receive closeSocketSafely 
]
