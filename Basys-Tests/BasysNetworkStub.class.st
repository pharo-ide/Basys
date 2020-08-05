Class {
	#name : #BasysNetworkStub,
	#superclass : #BasysNetwork,
	#instVars : [
		'lastDataPacket',
		'waitingDataTimeout'
	],
	#category : 'Basys-Tests'
}

{ #category : #operations }
BasysNetworkStub >> identifyLocalPeerOn: aConnection [
	"The stub implementation identifies peers by server address. 
	On local and remote side all connections belong to peer with same server address.
	In case of single server (in most of tests) it means the network with single remote peer"
	self sendDataPacket:  'identity:' , aConnection remotePeer address printString by: aConnection.
	^aConnection remotePeer address printString
]

{ #category : #initialization }
BasysNetworkStub >> initialize [
	super initialize.
	
	waitingDataTimeout := 100 milliSeconds
]

{ #category : #accessing }
BasysNetworkStub >> lastDataPacket [
	^lastDataPacket
]

{ #category : #operations }
BasysNetworkStub >> process: dataObject receivedFrom: aRemotePeer [ 
"	Transcript show: 'new data received: ', dataObject printString; cr." 
	lastDataPacket := dataObject.
	(lastDataPacket beginsWith: 'identity:') ifTrue: [ 
		aRemotePeer ensureIdentity: (lastDataPacket allButFirst: 'identity:' size)
	]
]

{ #category : #operations }
BasysNetworkStub >> receiveIncomingDataPacketFrom: aRemotePeer by: aBasysConnection [
	| stream |
	
	stream := aBasysConnection inputStream.
	stream timeout: waitingDataTimeout asMilliSeconds / 1000.0.
	stream ascii.
	^stream nextLine
]

{ #category : #operations }
BasysNetworkStub >> sendDataPacket: dataObject by: aBasysConnection [
	| stream |
	
	stream := aBasysConnection outputStream.
	
	stream nextPutAll: dataObject asString; crlf; flush.
	
"	Transcript show: 'new data sent: ', dataObject printString ; cr"
]

{ #category : #accessing }
BasysNetworkStub >> waitingDataTimeout [
	^ waitingDataTimeout
]

{ #category : #accessing }
BasysNetworkStub >> waitingDataTimeout: anObject [
	waitingDataTimeout := anObject
]
