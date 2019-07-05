"
I represent connection with remote peer inside Basys network.
I run process with incoming data loop which receive new data and run it processing asynchronously. 
Socket variable represents phisical connection to remote peer.  It is passed as argument to network to perform concrete operations: reading incoming data, processing it or sending new data.

Public API and Key Messages

- sendDataPacket:   dataObject
	sends dataObject to remote peer.
- acceptIncomingData 
	runs incoming data loop in separate process 
- close
	terminates incoming data process and closes socket

Instances are created by:
	BasysConnection inside: aBasysNetwork on: aSocket
 
Internal Representation and Key Implementation Points.

    Instance Variables
	incomingDataProcess:		<Process>
	network:		<BasysNetwork>
	processingPriority:		<Integer>	declares priority for incoming data process.
	remotePeer:		<BasysRemotePeer>
	socket:		<Socket>	represent phisical connection to remote peer.
"
Class {
	#name : #BasysConnection,
	#superclass : #Object,
	#instVars : [
		'network',
		'remotePeer',
		'socket',
		'incomingDataProcess',
		'processingPriority',
		'inputStream',
		'outputStream'
	],
	#category : 'Basys'
}

{ #category : #'instance creation' }
BasysConnection class >> inside: aBasysNetwork on: aSocket [

	^self new
		network: aBasysNetwork;
		socket: aSocket
]

{ #category : #controlling }
BasysConnection >> acceptIncomingData [

	incomingDataProcess := [
		[self incomingDataLoop] ifCurtailed: [ self closeSocketSafely ]		
	] forkAt: processingPriority named: self printString.
]

{ #category : #controlling }
BasysConnection >> close [
	"repeated process termination signals ProcessAlreadyTerminating exception which could stop image quit process with emergency screen. So we check here explicitly that process is not yet terminating"
	incomingDataProcess isTerminating ifFalse: [ incomingDataProcess terminate].
	self closeSocketSafely 
]

{ #category : #controlling }
BasysConnection >> closeSocketSafely [

	[socket closeAndDestroy] ifError: [ ]
]

{ #category : #controlling }
BasysConnection >> incomingDataLoop [

	[
		[
			[
				[self processIncomingDataPacket] on: ConnectionTimedOut, PrimitiveFailed do: [ :err | ]
		 	] repeat
		] on: BasysWrongProtocolError do: [ :err | self closeSocketSafely ]
	] on: ConnectionClosed do: [ :err |  ]
]

{ #category : #accessing }
BasysConnection >> incomingDataProcess [
	^ incomingDataProcess
]

{ #category : #accessing }
BasysConnection >> incomingDataProcess: anObject [
	incomingDataProcess := anObject
]

{ #category : #initialization }
BasysConnection >> initialize [
	super initialize.
	
	processingPriority := Processor userBackgroundPriority 
]

{ #category : #controlling }
BasysConnection >> inputStream [
	^inputStream ifNil: [ inputStream := network transferInputStreamOn: socket]

]

{ #category : #testing }
BasysConnection >> isValid [
	^socket isConnected
]

{ #category : #accessing }
BasysConnection >> network [
	^ network
]

{ #category : #accessing }
BasysConnection >> network: anObject [
	network := anObject
]

{ #category : #controlling }
BasysConnection >> outputStream [
	^outputStream ifNil: [ outputStream := network transferOutputStreamOn: socket]
]

{ #category : #controlling }
BasysConnection >> processIncomingDataPacket [

	| dataPacket process |
	
	dataPacket := network receiveIncomingDataPacketFrom: remotePeer by: self.
	process := remotePeer prepareProcessingOf: dataPacket.
	
	process run.
]

{ #category : #accessing }
BasysConnection >> processingPriority [
	^ processingPriority
]

{ #category : #accessing }
BasysConnection >> processingPriority: anObject [
	processingPriority := anObject
]

{ #category : #accessing }
BasysConnection >> remotePeer [
	^ remotePeer
]

{ #category : #accessing }
BasysConnection >> remotePeer: anObject [
	remotePeer := anObject
]

{ #category : #controlling }
BasysConnection >> sendDataPacket: dataObject [
	network sendDataPacket: dataObject by: self
]

{ #category : #accessing }
BasysConnection >> socket [
	^ socket
]

{ #category : #accessing }
BasysConnection >> socket: anObject [
	socket := anObject
]
