"
I represent  remote peer inside Basys network.
I maintain pool of connections which can be used to communicate with particular remote peer. 
I have two subclasses:
	- BasisActiveRemotePeer
		It can establish new connections by demand.
	- BasysPassiveRemotePeer
		It can't establish new connections. It only accepts connections from the outside. BasysServer is implemented for this. It accepts new connection and add it to corresponding passive remote peer.

Public API and Key Messages

- execute: aBlock 
	retrieves free connection from pool and execute given block with it. It can wait free connection if all in use or it can establish new one. It depends on type of peer: passive or active.
	
- sendDataPacket:   dataObject
	retrieves free connection from pool and send dataObject to it.

- close 
	closes all connections in pool

    Instance Variables
	address:		<TCPAddress>
	connectionPool:		<OPBasicPool>
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
	connectionPool is configured such way that #clear closes all connections"
	connectionPool clear
]

{ #category : #accessing }
BasysRemotePeer >> connectionCount [
	^connectionPool numberOfAvailableObjects 
]

{ #category : #accessing }
BasysRemotePeer >> connectionPool [
	^ connectionPool
]

{ #category : #accessing }
BasysRemotePeer >> connectionPool: anObject [
	connectionPool := anObject
]

{ #category : #private }
BasysRemotePeer >> ensureIdentity: peerId [

	self isIdentified ifTrue: [ 
		id = peerId ifFalse: [BasysIdentificationFailed signal]. "better name needed"
		^self ].

	network identifyRemotePeer: self as: peerId
]

{ #category : #operations }
BasysRemotePeer >> execute: aBlock [

	| error |
	connectionPool withPooled: [:connection |
		[aBlock value: connection] on: Error do: [ :err |
			BasysCommunicationFailed by: err.
			error := err]].
	
	error ifNotNil: [ error signal ]
]

{ #category : #accessing }
BasysRemotePeer >> freeConnectionCount [
	^connectionPool numberOfIdleObjects
]

{ #category : #controlling }
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

{ #category : #private }
BasysRemotePeer >> newConnection [
	^BasysConnection with: self inside: network
]

{ #category : #communication }
BasysRemotePeer >> openNewConnection [

	connectionPool openNewConnection
]

{ #category : #communication }
BasysRemotePeer >> receiveIncomingDataPacketBy: aSocket [
	
	^network receiveIncomingDataPacketFrom: self by: aSocket
]

{ #category : #operations }
BasysRemotePeer >> sendDataPacket: dataObject [ 

	self execute: [ :connection | connection sendDataPacket: dataObject ].

]

{ #category : #operations }
BasysRemotePeer >> waitConnection [
	| done |
	done := false.
	[
		[
			[self execute: [ :connection | done := true ]] 
				valueWithin: 100 milliSeconds onTimeout: [  ]
		] on: ConnectionTimedOut, OPTimedOutError do: [ :err | ].
	] doWhileFalse: [done]
]
