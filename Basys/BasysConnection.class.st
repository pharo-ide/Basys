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
		'outputStream',
		'isBusy'
	],
	#category : #Basys
}

{ #category : #'instance creation' }
BasysConnection class >> with: aBasysRemotePeer inside: aBasysNetwork [

	^self new
		network: aBasysNetwork;
		remotePeer: aBasysRemotePeer
]

{ #category : #controlling }
BasysConnection >> beBusy [
	isBusy := true
]

{ #category : #controlling }
BasysConnection >> beFree [
	isBusy := false
]

{ #category : #controlling }
BasysConnection >> close [
	incomingDataProcess ifNotNil: [
		incomingDataProcess isTerminated ifFalse: [incomingDataProcess terminate].
		incomingDataProcess := nil].
	
	self closeSocketSafely 
]

{ #category : #private }
BasysConnection >> closeSocketSafely [

	[socket closeAndDestroy] on: Error do: [ ]
]

{ #category : #private }
BasysConnection >> closeYourself [	
	"When incoming data process is terminated by any reason the connection closes itself here"
	self closeSocketSafely.
	incomingDataProcess := nil
]

{ #category : #private }
BasysConnection >> incomingDataLoop [

	[
		[
			[self processIncomingDataPacket] on: ConnectionTimedOut, PrimitiveFailed do: [ :err | ]
		] repeat
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
	
	isBusy := false
]

{ #category : #controlling }
BasysConnection >> inputStream [
	^inputStream ifNil: [ inputStream := network transferInputStreamOn: socket]

]

{ #category : #accessing }
BasysConnection >> isBusy [
	^ isBusy
]

{ #category : #accessing }
BasysConnection >> isBusy: anObject [
	isBusy := anObject
]

{ #category : #testing }
BasysConnection >> isOpened [
	^socket notNil
]

{ #category : #testing }
BasysConnection >> isValid [
	^self isOpened not or: [socket isConnected]
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
BasysConnection >> open [
	"First I establish new connection with a server and start incoming data process. 
	Then I should identify the local peer on server:
		- the server will add new connection to the peer which represents it. 
	With identification the server will have single remote peer with many pooled connections 
	which points to my (client) local peer. 
	Without identification server would always have separate peers for every connection"
	| remotePeerId |
	socket := network openNewConnectionTo: remotePeer address.
	
	self startIncomingDataProcess.
	
	[remotePeerId := network identifyLocalPeerOn: self.
	remotePeer ensureIdentity: remotePeerId] on: Error do: [ :err |
		self close.
		err pass ]
]

{ #category : #controlling }
BasysConnection >> outputStream [
	^outputStream ifNil: [ outputStream := network transferOutputStreamOn: socket]
]

{ #category : #private }
BasysConnection >> processIncomingDataPacket [

	| dataPacket |
	
	dataPacket := network receiveIncomingDataPacketFrom: remotePeer by: self.
	
	[ network process: dataPacket receivedFrom: remotePeer ] 
		forkAt: self processingPriority named: network printString
]

{ #category : #accessing }
BasysConnection >> processingPriority [
	^ processingPriority ifNil: [ network processingPriority ]
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
	self isOpened ifFalse: [ self open ].
	
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

{ #category : #private }
BasysConnection >> startIncomingDataProcess [

	incomingDataProcess := [
		[self incomingDataLoop] ifCurtailed: [ self closeYourself ]		
	] forkAt: self processingPriority named: self printString.
]
