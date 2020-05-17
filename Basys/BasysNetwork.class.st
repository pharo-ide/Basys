"
I represent bidirectional asynchronous network of connected peers. 

I am abstract class and my subclasses should define concrete protocol of communication, what format to use and what to do with incoming data. 
I supply infrastructure to manage connections and fork data processing . I model connected peers as first class objects - subclasses of BasysPeer:
	- BasysLocalPeer represents current local peer. It supplies id for local peer identification.
	- BasysRemotePeer represents remote peers. Remote peers maintain connection pools which is used to communicate with remote side:
		remotePeer execute: [ :connection |  connection sendDataPacket: dataObject ].
	or simple version:
		remotePeer sendDataPacket: dataObject.

Connections represented by BasysConnection instances. They hold socket for sending and receiving data which can be performed simultaneously. 
Each connection run incoming data process which is waiting for new data from remote side. When data is received connection starts another process to handle it. So receiving and processing data executed asynchronously. 

There are two types of remote peers:
	- BasysActiveRemotePeer knows how to establish new connections. It represents server on client side. 
	- BasysPassiveRemotePeer accepts new connections from the outside. It has no knowledge how to produce new connections. It represents client on server side. 

You can ask me for remote peer at IP address: 
	remotePeer := network remotePeerAt: aTCPAddress
It will create new active peer if it is not exists yet. Then you can perform requests with peer (remotePeer execute: aBlock). If no connections exist yet or all connections are busy then new connection will be established and added to peer connection pool.

To accept connections from clients BasysServer should be started:
	server := network startServer.
By default OS will assign the free port for server. Or concrete port can be specified:
	server := network startServerOn: portNumber
For every new connection BasysServer asks network for new passive peer and sends incoming connection to it. Then connection runs incoming data process to start interaction with client.
When physical connection is established client should identify it: all connections from same client should be bound to single peer instance on server.
During identification server can detect that new connection belongs to existed peer. In that case connection will be migrated to it and anonymous peer wil be removed. Otherwise anonymous peer become identified: It will have same id as connected local peer from remote side.
On client side identification will return server local peer id. Client will assign it to active peer which initiated this connection.
If client is server too then it is possible that it already contains passive peer with same id (which points to same server peer). In that case I will convert existed peer to active peer and migrate new connection to it. Original active peer will be removed.
Described logic ensures that server is represented on client by single peer and client is represented on server by single peer. 

Concrete network implementations should define four operations:

- sendDataPacket: dataObject by: aSocket 
	How to send data to remote side. What format and protocol should be used 
- receiveIncomingataPacketFrom: aRemotePeer by: aSocket 
	How to receive data from remote side. What format and protocol should be used 
- process: dataObject receivedFrom: aRemotePeer 
	What to do with incoming data. 
- identifyLocalPeerOn:  aConnection 
	How to identify new connections from client on remote side
 
I am based on TCP protocol but this knowledge is abstracted and actual communication layer can be substituted. I use communicationLibrary for this to produce primitive network objects like sockets and data streams. Now it is TCPPharoNetworkLibrary.
 
    Instance Variables
	communicationLibrary:		<TCPNetworkLibrary>
	connectionTimeout:		<Duration>
	localPeer:		<BasysLocalPeer>
	processingPriority:		<Integer>
	remotePeers:		<Collection of <BasysRemotePeer>>
"
Class {
	#name : #BasysNetwork,
	#superclass : #Object,
	#instVars : [
		'communicationLibrary',
		'connectionTimeout',
		'processingPriority',
		'localPeer',
		'remotePeers'
	],
	#classInstVars : [
		'defaultConnectionTimeout'
	],
	#category : #Basys
}

{ #category : #accessing }
BasysNetwork class >> defaultConnectionTimeout [
	^defaultConnectionTimeout ifNil: [ 10 seconds ]
]

{ #category : #accessing }
BasysNetwork class >> defaultConnectionTimeout: aDuration [
	defaultConnectionTimeout := aDuration
]

{ #category : #accessing }
BasysNetwork >> addNewPeerForAcceptingConnections [

	| newPeer |
	newPeer := BasysPassiveRemotePeer inside: self.
	remotePeers add: newPeer.
	^newPeer
]

{ #category : #accessing }
BasysNetwork >> addRemotePeer: aRemotePeer [
	remotePeers add: aRemotePeer
]

{ #category : #controlling }
BasysNetwork >> close [
	"This method to really close all connected peers with existing connections.
	 As result all peers become closed and will forbid any remote communication
	When peer is closing it removes itself from network. That's why we enumerate on copy"
	remotePeers copy do: [ :each | each close ].
	remotePeers removeAll
]

{ #category : #controlling }
BasysNetwork >> closeConnections [
	"This method only close existing connections. All peers are stayed working"
	remotePeers do: [ :each | each closeConnections ]
]

{ #category : #accessing }
BasysNetwork >> communicationLibrary [
	^ communicationLibrary
]

{ #category : #accessing }
BasysNetwork >> communicationLibrary: anObject [
	communicationLibrary := anObject
]

{ #category : #accessing }
BasysNetwork >> connectionTimeout [
	^ connectionTimeout ifNil: [ self class defaultConnectionTimeout ]
]

{ #category : #accessing }
BasysNetwork >> connectionTimeout: aDuration [
	connectionTimeout := aDuration
]

{ #category : #accessing }
BasysNetwork >> connectionsCount [
	remotePeers ifEmpty: [ ^0 ].
	
	^remotePeers sum: [ :each | each connectionsCount ]
]

{ #category : #operations }
BasysNetwork >> createConnectionOn: aSocket [
 
	^BasysConnection inside: self on: aSocket
]

{ #category : #operations }
BasysNetwork >> establishNewConnectionTo: anAddress [

	^communicationLibrary openConnectionTo: anAddress timeout: self connectionTimeout
]

{ #category : #operations }
BasysNetwork >> identifyLocalPeerOn: aConnection [

	self subclassResponsibility 
]

{ #category : #initialization }
BasysNetwork >> initialize [
	super initialize.
	
	communicationLibrary := TCPPharoNetworkLibrary.
	processingPriority := Processor userBackgroundPriority.
	localPeer := BasysLocalPeer inside: self.
	remotePeers := OrderedCollection new.
	
]

{ #category : #accessing }
BasysNetwork >> localPeer [
	^ localPeer
]

{ #category : #accessing }
BasysNetwork >> localPeer: anObject [
	localPeer := anObject
]

{ #category : #accessing }
BasysNetwork >> localPeerId [
	^ localPeer id
]

{ #category : #operations }
BasysNetwork >> process: dataObject receivedFrom: aRemotePeer [

	self subclassResponsibility 
]

{ #category : #accessing }
BasysNetwork >> processingPriority [
	^ processingPriority
]

{ #category : #accessing }
BasysNetwork >> processingPriority: anObject [
	processingPriority := anObject
]

{ #category : #operations }
BasysNetwork >> receiveIncomingDataPacketFrom: aRemotePeer by: aBasysConnection [

	self subclassResponsibility 
]

{ #category : #accessing }
BasysNetwork >> remotePeerAt: anAddress [ 
	| peer |
	^remotePeers detect: [ :each | each isBelongsTo: anAddress ] ifNone: [ 
		peer := BasysActiveRemotePeer inside: self at: anAddress.
		remotePeers add: peer.
		peer]
]

{ #category : #accessing }
BasysNetwork >> remotePeerWithId: peerId ifAbsent: aBlock [

	^remotePeers detect: [ :each | each id = peerId ] ifNone: aBlock
]

{ #category : #accessing }
BasysNetwork >> remotePeers [
	^ remotePeers
]

{ #category : #accessing }
BasysNetwork >> remotePeers: anObject [
	remotePeers := anObject
]

{ #category : #accessing }
BasysNetwork >> removeRemotePeer: aRemotePeer [
	remotePeers remove: aRemotePeer ifAbsent: [  ]
]

{ #category : #operations }
BasysNetwork >> sendDataPacket: dataObject by: aBasysConnection [

	self subclassResponsibility 
]

{ #category : #controlling }
BasysNetwork >> startServer [
	| server |
	server := BasysServer for: self.
	server start.
	^server
]

{ #category : #controlling }
BasysNetwork >> startServerOn: portNumber [
	| server |
	server := BasysServer for: self on: portNumber.
	server start.
	^server
]

{ #category : #'input/output' }
BasysNetwork >> transferInputStreamOn: aSocket [
	^(communicationLibrary inputStreamOn: aSocket) binary
]

{ #category : #'input/output' }
BasysNetwork >> transferOutputStreamOn: aSocket [
	^(communicationLibrary outputStreamOn: aSocket) binary
]
