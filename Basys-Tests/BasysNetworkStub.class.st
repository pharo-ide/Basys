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
	"As a stub I only maintain peer identity on local side.
	On local side all connections from the active peer will belong to it using same server address.
	But on remote side the separate peer instances will be created for every new connection
	For testing purposes it is enough behavior 	assuming that most of the tests are about single connection logic.
	For multiple connections tests explicitly perform identification on server side"
	^aConnection remotePeer address
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
