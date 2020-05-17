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
		'connectionPool'
	],
	#category : 'Basys'
}

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

{ #category : #controlling }
BasysRemotePeer >> close [
	"Here we really close peer. It will be converted to BasysClosedRemotePeer 
	which forbid any remote communication. Also we remove this peer from network".
	
	connectionPool creator: [ BasysRemotePeerClosed signal ].
	
	BasysClosedRemotePeer adoptInstance: self.	
	self closeConnections.	
	network removeRemotePeer: self.
	
	"it is hook to immediatelly raise error by creator.
	With maxActiveObjects=0 pool will be waiting for new connection from outside and then it will fail by timeout error. But we want more precise failure"	
	connectionPool maxActiveObjects: Float infinity.
]

{ #category : #controlling }
BasysRemotePeer >> closeConnections [
	"Here we just close existing connections. Peer is stayed working.
	connectionPool is configured such way that clear closes all connections"
	connectionPool clear
]

{ #category : #accessing }
BasysRemotePeer >> connectionPool [
	^ connectionPool
]

{ #category : #accessing }
BasysRemotePeer >> connectionPool: anObject [
	connectionPool := anObject
]

{ #category : #accessing }
BasysRemotePeer >> connectionsCount [
	^connectionPool numberOfAvailableObjects 
]

{ #category : #initialization }
BasysRemotePeer >> createNewConnectionPool [

	connectionPool := OPBasicPool new.
	connectionPool maxWaitForBorrow: 45. "milliSeconds"
	connectionPool validator: [ :c | c isValid ].
	connectionPool destroyer: [ :connection | connection close ].

	self prepareConnectionPool

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
BasysRemotePeer >> freeConnectionsCount [
	^connectionPool numberOfIdleObjects
]

{ #category : #controlling }
BasysRemotePeer >> importConnectionsFrom: anotherConnectionsPool [

	anotherConnectionsPool migrateObjectsInto: connectionPool andDo: [ :each | each remotePeer: self ]
]

{ #category : #initialization }
BasysRemotePeer >> initialize [
	super initialize.
	
	self createNewConnectionPool
]

{ #category : #testing }
BasysRemotePeer >> isBelongsTo: anAddress [
	^address = anAddress
]

{ #category : #testing }
BasysRemotePeer >> isClosed [

	^false
]

{ #category : #testing }
BasysRemotePeer >> isConnected [

	^connectionPool isEmpty not
]

{ #category : #testing }
BasysRemotePeer >> isIdentified [

	^id notNil
]

{ #category : #accessing }
BasysRemotePeer >> localPeerId [
	^network localPeerId
]

{ #category : #accessing }
BasysRemotePeer >> network: aBasysNetwork [
	super network: aBasysNetwork.
	connectionPool maxWaitForBorrow: (network connectionTimeout * 2) asMilliSeconds.
]

{ #category : #initialization }
BasysRemotePeer >> prepareConnectionPool [

	self subclassResponsibility 
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
