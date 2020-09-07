"
I represent a remote peer inside a BasysNetwork.
I maintain a pool of connections which can be used to communicate with remote side which I represent. 
There are three types of connection pools which are responsible for my connectivity properties:

- BasisActiveConnectionPool. It can open new connections by demand when nothing exists or all existing connections are busy.

- BasysPassiveConnectionPool. It can't establish new connections. It can only use what was received from the outside. For example connections are added to the peer (and its connection pool) from the BasysServer. It rans the connection loop and adds the every incomming connection to the peer instances.

- BasysClosedConnectionPool. It represents a closed state of remote peer which prevents any interaction with the remote side. Any message to this pool throws a BasysRemotePeerClosed error.

Public API and Key Messages

- connectToLocalPeerFor: connectionBlock. It retrieves a free connection from the pool and executes a given block with it. It can wait for a free connection if all are in use or it can establish a new one depending on the type of peer: passive or active.
	
- sendObject: anObject. It retrieves a free connection from the pool and sends anObject to it.

- closeConnections. It closes all connections in pool. Peer continue working after that.

- close. It completely closes any interaction with the remote side. It closes all connections in the pool and replaces it with closed version (see above).

    Instance Variables
	address:		<TCPAddress>
	connectionPool:		<BasysConnectionPool>
"
Class {
	#name : #BasysRemotePeer,
	#superclass : #BasysPeer,
	#instVars : [
		'address',
		'connectionPool',
		'maxConnections'
	],
	#category : #Basys
}

{ #category : #'instance creation' }
BasysRemotePeer class >> inside: aBasysNetwork at: anAddress [

	^(self inside: aBasysNetwork)
		beActiveWith: anAddress
]

{ #category : #communication }
BasysRemotePeer >> addNewConnectionOpenedRemotelyUsing: aSocket [

	| connection |
	connection := self newConnection.
	connection socket: aSocket.
	connectionPool addConnection: connection.
	connection startIncomingDataProcess
]

{ #category : #accessing }
BasysRemotePeer >> address [
	^ address
]

{ #category : #accessing }
BasysRemotePeer >> address: anObject [
	address := anObject
]

{ #category : #printing }
BasysRemotePeer >> addressString [

	address ifNil: [ ^'Unknown address' ].
	
	^String streamContents: [ :s | address printSimpleStringOn: s ]
]

{ #category : #initialization }
BasysRemotePeer >> beActiveWith: anAddress [

	address := anAddress.
	connectionPool beActive
]

{ #category : #initialization }
BasysRemotePeer >> bePassive [

	connectionPool bePassive
]

{ #category : #controlling }
BasysRemotePeer >> close [
	"Here we really close peer. The pool will be converted to BasysClosedConnectionPool 
	which forbid any remote communication. Also we remove this peer from the network.
	The pool close operation will close all existing connections".
	
	connectionPool close.
	network removeRemotePeer: self
]

{ #category : #controlling }
BasysRemotePeer >> closeConnections [
	"Here we just close existing connections. Peer is stayed working.
	ConnectionPool performs a close of all opened connections and removes them"
	connectionPool clear
]

{ #category : #operations }
BasysRemotePeer >> connectToLocalPeerFor: communicationBlock [
	"Method allocates a connection between a local peer and a receiver 
	to perform a communication using given communicationBlock"
	connectionPool allocateConnectionFor: communicationBlock
]

{ #category : #accessing }
BasysRemotePeer >> connectionCount [
	^connectionPool openSize
]

{ #category : #accessing }
BasysRemotePeer >> connectionPool [
	^ connectionPool
]

{ #category : #accessing }
BasysRemotePeer >> connectionPool: anObject [
	connectionPool := anObject
]

{ #category : #communication }
BasysRemotePeer >> ensureIdentity: peerId [

	self isIdentified ifTrue: [ 
		id = peerId ifFalse: [BasysIdentificationFailed signal]. "better name needed"
		^self ].

	network identifyRemotePeer: self as: peerId
]

{ #category : #accessing }
BasysRemotePeer >> freeConnectionCount [
	^connectionPool freeSize
]

{ #category : #communication }
BasysRemotePeer >> importConnectionsFrom: aRemotePeer [

	aRemotePeer connectionPool migrateConnectionsInto: connectionPool
]

{ #category : #initialization }
BasysRemotePeer >> initialize [
	super initialize.
	
	connectionPool := BasysPassiveConnectionPool of: self
]

{ #category : #testing }
BasysRemotePeer >> isActive [ 
	^connectionPool isActive
]

{ #category : #testing }
BasysRemotePeer >> isBelongsTo: anAddress [
	^address = anAddress
]

{ #category : #testing }
BasysRemotePeer >> isClosed [

	^connectionPool isClosed
]

{ #category : #testing }
BasysRemotePeer >> isConnected [

	^connectionPool isEmpty not
]

{ #category : #testing }
BasysRemotePeer >> isIdentified [

	^id notNil
]

{ #category : #testing }
BasysRemotePeer >> isPassive [ 
	^connectionPool isPassive
]

{ #category : #accessing }
BasysRemotePeer >> localPeerId [
	^network localPeerId
]

{ #category : #accessing }
BasysRemotePeer >> maxConnections [
	^maxConnections ifNil: [ network maxConnectionsPerPeer ]
]

{ #category : #accessing }
BasysRemotePeer >> maxConnections: anObject [
	maxConnections := anObject
]

{ #category : #accessing }
BasysRemotePeer >> network: aBasysNetwork [
	super network: aBasysNetwork
]

{ #category : #factory }
BasysRemotePeer >> newConnection [
	^BasysConnection with: self inside: network
]

{ #category : #communication }
BasysRemotePeer >> openNewConnection [

	connectionPool openNewConnection
]

{ #category : #communication }
BasysRemotePeer >> removeClosedConnection: aConnection [

	connectionPool removeClosedConnection: aConnection
]

{ #category : #operations }
BasysRemotePeer >> sendObject: anObject [ 

	self connectToLocalPeerFor: [:connection | 	connection sendObject: anObject ]

]

{ #category : #operations }
BasysRemotePeer >> trySendObjectIfConnected: anObject [ 

	self isConnected ifFalse: [ ^false ].
	
	^[self sendObject: anObject. true]
		on: ConnectionTimedOut, BasysIdentificationFailed , BasysNoConnection , BasysRemotePeerClosed
		do: [ :err | false ]

]

{ #category : #operations }
BasysRemotePeer >> waitConnection [
	
	connectionPool waitOpenedConnection 
]
