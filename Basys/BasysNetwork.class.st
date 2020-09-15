"
I represent bidirectional asynchronous network of connected peers. 

I am abstract class and my subclasses should define concrete protocol of communication: 
	- what format to use and what to do with incoming data. 
I supply infrastructure to manage connections and fork data processing . I model connected peers as first class objects - subclasses of BasysPeer:
	- BasysLocalPeer represents current local peer. It supplies id for local peer identification.
	- BasysRemotePeer represents remote peers. Each remote peer maintains a pool of connections to communicate with remote side:

		remotePeer connectToLocalPeerFor: [ :connection |  connection sendObject: dataObject ].

or a simple version:

		remotePeer sendObject: dataObject.

Connections are represented by BasysConnection instances. They hold socket for sending and receiving objects simultaneously. 
Each connection runs incoming data process which is waiting for new objects from the remote side. When object is received the connection starts another process to handle it. The receiving and the processing of objects are performed asynchronously. 

Remote peers can be active or passive depending on their capabilities to open new connections with a remote side:
	- an active peer opens connections by demand when nothing exits or when all existing connections are busy. BasysActiveConnectionPool implements this logic.
	- a passive peer only uses connections received from the outside (for example from the BasysServer). When nothing exists it simply throws an error.

In classic client/server application an active peer represents a remote side on the client. It establishes connections with a remote server. And a passive peer is a server side instance representing the connected client. Obviously the server side peer can't open new connections with the client.
	
Remote peers are configured with maximum number of connections (#maxConnections):
- an active peer never opens more connections than allowed number
- peers do not allow to add more connection than allowed number (for exampe BasysServer will close every new connection which exceeds this limit)
By default the maximum connection number is based on default network setting #maxConnectionsPerPeer.

If you know the address of remote peer (where there is a running BasysServer) you can get an instance of BasysRemotePeer to interact with it: 

	remotePeer := network remotePeerAt: aTCPAddress

It will create new active peer instance if it is not exists yet or it will return existing one. 
With peer instance you can send objects to the remote side: 	
	
	remotePeer sendObject: anObject. 

When no connections exist or all connections are busy the new connection will be established automaticaly and added to the peer connection pool.

To accept connections from clients a BasysServer should be started:

	server := network startServer.

By default OS will assign the free port for the server. Or concrete port can be specified:

	server := network startServerOn: portNumber

For every new connection BasysServer asks network for new passive peer and sends incoming connection to it. Then connection starts incoming data process which drives the interaction with the client.

When the physical connection is established the client should identify it: 
	- all connections from the same client should be bound to the single peer instance on server and the other way.

During the identification process the server can detect that new connection belongs to existed peer. In that case the connection will be migrated into it and an anonymous peer will be removed. Otherwise the anonymous peer will become identified: 
	- it will have the same id as connected local peer from the remote side.	
On the client side the identification will return the server local peer id. The client will assign it to the active peer which initiates this connection.

When the client is also have a running server then it is possible that there is already a registered passive peer with same id (which points to same server peer). In that case the network will also convert the existing peer to the active peer and migrate new connection into it. Original active peer will be removed.

Described logic ensures that the server is represented on the client by a single peer and the client is represented on the server by a single peer. 

Concrete network implementations should define four operations:

- sendObject: anObject by: aBasysConnection. How to send anObject to the remote side: what a format and a protocol should be used.

- receiveObjectBy: aBasysConnection. How to receive an object from the remote side: what a format and a protocol should be used.

- process: anObject receivedFrom: aRemotePeer. What to do with incoming object. 
	
- identifyLocalPeerOn: aBasysConnection. How to identify new connections from the local side to remote side.
 
I am based on TCP/IP protocol but this knowledge is abstracted and actual communication layer can be substituted. I use communicationLibrary for this to produce primitive network objects like sockets and data streams. Now it is TCPPharoNetworkLibrary.
This abstraction is probably too naive and needs to be improved to achieve this goal.
 
    Instance Variables
	communicationLibrary:		<TCPNetworkLibrary>
	connectionTimeout:		<Duration>
	maxConnectionsPerPeer:		<Integer>
	processingPriority:		<Integer>
	localPeer:		<BasysLocalPeer>
	peerRegistry:		<BasysPeerRegistry>
"
Class {
	#name : #BasysNetwork,
	#superclass : #Object,
	#instVars : [
		'communicationLibrary',
		'connectionTimeout',
		'maxConnectionsPerPeer',
		'processingPriority',
		'localPeer',
		'peerRegistry'
	],
	#classInstVars : [
		'connectionTimeout',
		'maxConnectionsPerPeer'
	],
	#category : #Basys
}

{ #category : #accessing }
BasysNetwork class >> connectionTimeout [
	^connectionTimeout ifNil: [ self defaultConnectionTimeout ]
]

{ #category : #accessing }
BasysNetwork class >> connectionTimeout: aDuration [
	connectionTimeout := aDuration
]

{ #category : #accessing }
BasysNetwork class >> defaultConnectionTimeout [
	^10 seconds
]

{ #category : #accessing }
BasysNetwork class >> defaultMaxConnectionsPerPeer [
	^10
]

{ #category : #accessing }
BasysNetwork class >> maxConnectionsPerPeer [
	^maxConnectionsPerPeer ifNil: [ self defaultMaxConnectionsPerPeer ]
]

{ #category : #accessing }
BasysNetwork class >> maxConnectionsPerPeer: anInteger [
	maxConnectionsPerPeer := anInteger
]

{ #category : #accessing }
BasysNetwork >> addNewRemotePeer [

	^peerRegistry addRemotePeer: self newRemotePeer
]

{ #category : #accessing }
BasysNetwork >> addRemotePeer: aRemotePeer [
	peerRegistry addRemotePeer: aRemotePeer
]

{ #category : #controlling }
BasysNetwork >> close [
	"Method closes all remote peers and their connections.
	As result all peers become closed and will forbid any remote communication"
	peerRegistry closeRemotePeers
]

{ #category : #controlling }
BasysNetwork >> closeConnections [
	"This method only closes existing connections. All peers are stayed working"
	peerRegistry closeConnections
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
BasysNetwork >> connectionCount [
	
	^peerRegistry connectionCount
]

{ #category : #accessing }
BasysNetwork >> connectionTimeout [
	^ connectionTimeout ifNil: [ self class connectionTimeout ]
]

{ #category : #accessing }
BasysNetwork >> connectionTimeout: aDuration [
	connectionTimeout := aDuration
]

{ #category : #operations }
BasysNetwork >> identifyLocalPeerOn: aConnection [

	self subclassResponsibility 
]

{ #category : #operations }
BasysNetwork >> identifyRemotePeer: aRemotePeer as: peerId [
	"Identification process ensures the only peer instance for all connections established with same remote side. For users it is transparent:
	- when user retrieves new active peer using an address the network can already have a passive peer created from incoming connections. The identification in that case will convert new peer to registered one. The become operation here transparently push the registed peer into the user.
	- when server accepts new connection it creates unidentified passive peer. Then the identification can find the registered peer and it will convert newly created instance into it"
	| identifiedPeer |
	identifiedPeer := peerRegistry identifyRemotePeer: aRemotePeer as: peerId.
	identifiedPeer == aRemotePeer ifTrue: [ 
		"Here aRemotePeer is the only peer registered with given peerId" 
		^self ].
	
	[identifiedPeer importConnectionsFrom: aRemotePeer] on: BasysTooManyConnections do: [:err | 
		aRemotePeer closeConnections ].
	aRemotePeer isActive ifTrue: [ identifiedPeer beActiveWith: aRemotePeer address ].
	aRemotePeer becomeForward: identifiedPeer 
]

{ #category : #initialization }
BasysNetwork >> initialize [
	super initialize.
	
	communicationLibrary := TCPPharoNetworkLibrary.
	processingPriority := Processor userBackgroundPriority.
	localPeer := self newLocalPeer.
	peerRegistry := BasysPeerRegistry new
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

{ #category : #accessing }
BasysNetwork >> maxConnectionsPerPeer [
	^ maxConnectionsPerPeer ifNil: [ self class maxConnectionsPerPeer ]
]

{ #category : #accessing }
BasysNetwork >> maxConnectionsPerPeer: anInteger [
	maxConnectionsPerPeer := anInteger
]

{ #category : #factory }
BasysNetwork >> newLocalPeer [ 
	^BasysLocalPeer inside: self
]

{ #category : #factory }
BasysNetwork >> newRemotePeer [ 
	^BasysRemotePeer inside: self
]

{ #category : #operations }
BasysNetwork >> openNewConnectionTo: anAddress [

	^communicationLibrary openConnectionTo: anAddress timeout: self connectionTimeout
]

{ #category : #operations }
BasysNetwork >> process: anObject receivedFrom: aRemotePeer [

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
BasysNetwork >> receiveObjectBy: aBasysConnection [

	self subclassResponsibility 
]

{ #category : #accessing }
BasysNetwork >> remotePeerAt: anAddress [ 

	^peerRegistry remotePeerAt: anAddress ifAbsentRegister: [ self newRemotePeer ]
]

{ #category : #accessing }
BasysNetwork >> remotePeers [
	^ peerRegistry remotePeers
]

{ #category : #accessing }
BasysNetwork >> removeRemotePeer: aRemotePeer [
	peerRegistry removeRemotePeer: aRemotePeer 
]

{ #category : #operations }
BasysNetwork >> sendObject: anObject by: aBasysConnection [

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
