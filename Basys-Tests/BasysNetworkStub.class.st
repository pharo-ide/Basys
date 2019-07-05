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
	lastDataPacket := dataObject
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
