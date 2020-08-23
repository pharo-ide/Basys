"
I am an example implementation of BasysNetwork suitable for acceptance testing of Basys system (see BasysRealCommunicationTests).

I use simple string lines as transferred data and I keep last received string in my variable #lastDataPacked. It allows very simple tests to specify how network is working under various scenariuos.

The main trick is an implementation of identification logic. I identify peers by a port number of the server:
- on local and remote side all connections belong to the peer with same server port.
In case of single host and server (in most of tests) it means the network with single remote peer.

So to achieve all of that I implement four required network functions:

- sendDataPacket: dataObject by: aBasysConnection.
I simply write #asString of given dataOobject into the output stream of the connection with terminating #crlf symbol.

- receiveIncomingataPacketFrom: aRemotePeer by: aBasysConnection. 
I simply read the entire string line from the input stream of the connection.
To allow a simulation of a timeout conditions I configure a given socket with my variable #waitingDataTimeout. 

- process: dataObject receivedFrom: aRemotePeer.

I simply store the received dataObject into the #lastDataPacket variable. 
And in addition I handle here an identification query from the remove side when the received string has ""identity:"" prefix.

- identifyLocalPeerOn:  aConnection. 
I simply send a connection port number with ""identity:"" prefix into given aRemotePeer. And the sent port is returned as the result.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	lastDataPacket:		<String>
	waitingDataTimeout:		<Duration>
"
Class {
	#name : #BasysNetworkExample,
	#superclass : #BasysNetwork,
	#instVars : [
		'lastDataPacket',
		'waitingDataTimeout'
	],
	#category : #'Basys-Tests'
}

{ #category : #operations }
BasysNetworkExample >> identifyLocalPeerOn: aConnection [
	"This example implementation identifies peers by a port number of server. 
	On local and remote side all connections belong to peer with same server port.
	In case of single host and server (in most of tests) it means the network with single remote peer"
	self sendDataPacket:  'identity:' , aConnection remotePeer address port printString by: aConnection.
	^aConnection remotePeer address port
]

{ #category : #initialization }
BasysNetworkExample >> initialize [
	super initialize.
	
	waitingDataTimeout := 100 milliSeconds
]

{ #category : #accessing }
BasysNetworkExample >> lastDataPacket [
	^lastDataPacket
]

{ #category : #operations }
BasysNetworkExample >> process: dataObject receivedFrom: aRemotePeer [ 
	"	Transcript show: 'new data received: ', dataObject printString; cr." 
	lastDataPacket := dataObject.
	(lastDataPacket beginsWith: 'identity:') ifTrue: [ 
		aRemotePeer ensureIdentity: (lastDataPacket allButFirst: 'identity:' size) asNumber
	]
]

{ #category : #operations }
BasysNetworkExample >> receiveIncomingDataPacketFrom: aRemotePeer by: aBasysConnection [
	| stream |
	
	stream := aBasysConnection inputStream.
	stream timeout: waitingDataTimeout asMilliSeconds / 1000.0.
	stream ascii.
	^stream nextLine
]

{ #category : #operations }
BasysNetworkExample >> sendDataPacket: dataObject by: aBasysConnection [
	| stream |
	
	stream := aBasysConnection outputStream.
	
	stream nextPutAll: dataObject asString; crlf; flush.
	
"	Transcript show: 'new data sent: ', dataObject printString ; cr"
]

{ #category : #accessing }
BasysNetworkExample >> waitingDataTimeout [
	^ waitingDataTimeout
]

{ #category : #accessing }
BasysNetworkExample >> waitingDataTimeout: anObject [
	waitingDataTimeout := anObject
]
