"
I represent a connection with a remote peer inside a BasysNetwork.
I run a process with an incoming data loop which receives new object and processes it asynchronously. 
Socket variable represents a physical connection with remote side. It is passed as an argument to the network to perform concrete operations: reading incoming object, processing received object and sending given object.

Public API and Key Messages

- sendObject:   dataObject. It sends dataObject to the remote peer.

- startIncomingDataProcess. It runs an incoming data loop in a separate process 

- close. It terminates the incoming data process and closes a socket

Instances are created by:
	BasysConnection iwith: aBasysRemotePeer inside: aBasysNetwork
 
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
BasysConnection >> beOpened [
	self isOpened ifFalse: [ self open ]

]

{ #category : #controlling }
BasysConnection >> close [
	"The actual connection close is always performed from #incomingDataProcess.
	When it detects the termination of incomping data loop (by any reason like error or debugger) 
	the process sends #close to the connection where it cleans all required parts (like socket).	
	From the other side the close can be initiated from the outside of the connection.
	For example user can decide to close connection manualy.
	This scenario is simply handled by terminating the data process:
	- the termination triggers the actual close (recursive call here) from the context of data process.	
	And there are two cases where the actual close needs to be performed directly: 
		- data process is not started yet
		- data process is in very beggining step where it is not able to handle the termination"		
	(incomingDataProcess notNil and: [ incomingDataProcess isActiveProcess not ]) ifTrue: [
		"Here the close is performed from the outside of the connection (not under the data process)"	
		incomingDataProcess terminate.
		"If terminate really did the close it will nil the process variable. And therefore the return"
		incomingDataProcess ifNil: [ ^self ] ].
		
	incomingDataProcess := nil.
	self closeSocketSafely.
	remotePeer removeClosedConnection: self
]

{ #category : #private }
BasysConnection >> closeSocketSafely [

	[socket closeAndDestroy] on: Error do: [ ]
]

{ #category : #private }
BasysConnection >> incomingDataLoop [

	[
		[
			[self processIncomingObject] on: ConnectionTimedOut, PrimitiveFailed do: [ :err | ]
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
BasysConnection >> isIdentified [
	^remotePeer isIdentified
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
BasysConnection >> localPeerId [
	^network localPeerId
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
BasysConnection >> processIncomingObject [

	| receivedObject |
	
	receivedObject := network receiveObjectBy: self.
	
	[ network process: receivedObject receivedFrom: remotePeer ] 
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

{ #category : #accessing }
BasysConnection >> remotePeerId [
	^ remotePeer id
]

{ #category : #controlling }
BasysConnection >> sendObject: anObject [
	self beOpened.
	
	network sendObject: anObject by: self
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
		[self incomingDataLoop] ensure: [ self close ]		
	] forkAt: self processingPriority named: self printString
]
