"
I represent remote peer inside Basys network which can only accepts new connections from the outside (like running BasysServer). I have no knowledge how to connect to remote side.
I can be treated as peer which represent client on server. But when server can connect to client too then this definition becomes not valid. Actually in such cases basys network will convert me to active peer. And both sides (client and server) will have BasysActiveRemotePeer instances.

I created by network for any incoming connection. After that client starts identification procedure and my network can detect that existed peer corresponds to my connection. My connection will be imported to it. And I will be removed from network.
If identification procedure detects that I am new connected peer then I stay in network to be used in work.

Public API and Key Messages

- acceptNewConnectionEstablishedBy: aSocket
	It creates new connection instance by network and adds it to my connection pool
	
- beIdentifiedAs: peerId 
	It searches existed network peer with given peerId. If such peer exists I will migrate my connections to it and remove myself from network.
	Otherwise It will assign given peerId to my id.

- becomeActiveToReplaceSamePeer: aBasysActiveRemotePeer
	It migrates given peer connections to me and converts me to active remote peer

When I am created I configure my connection pool to wait free connections when all are busy. It means that new requests will be waiting until busy connections become free or new connections will be accepted from outside.
"
Class {
	#name : #BasysPassiveRemotePeer,
	#superclass : #BasysRemotePeer,
	#category : 'Basys'
}

{ #category : #private }
BasysPassiveRemotePeer >> addNewConnection: aBasysConnection [

	aBasysConnection remotePeer: self.
	
	connectionPool objectToPool: aBasysConnection.
	connectionPool fixMaxActiveObjects
]

{ #category : #communication }
BasysPassiveRemotePeer >> addNewConnectionOpenedUsing: aSocket [

	| connection |
	connection := self newConnection.
	connection completeRemoteOpeningUsing: aSocket.
	
	connectionPool objectToPool: connection.
	connectionPool fixMaxActiveObjects
]

{ #category : #controlling }
BasysPassiveRemotePeer >> beIdentifiedAs: peerId [
	
	| registeredPeer |
	registeredPeer := network remotePeerWithId: peerId ifAbsent: [ 
		id := peerId. ^self ].
	
	self == registeredPeer ifTrue: [ self error: 'Should not happen' ].
	
	registeredPeer importConnectionsFrom: connectionPool.
	network removeRemotePeer: self.
	"following become required because imported connections 
	could hold old peer instance on incoming process stack"
	self becomeForward: registeredPeer.
	^registeredPeer 
]

{ #category : #controlling }
BasysPassiveRemotePeer >> becomeActiveToReplaceSamePeer: aBasysActivePeer [

	address := aBasysActivePeer address.
	network removeRemotePeer: aBasysActivePeer.
	self primitiveChangeClassTo: aBasysActivePeer.
	self prepareConnectionPool.
	connectionPool maxActiveObjects: nil.
	
	aBasysActivePeer becomeForward: self
]

{ #category : #initialization }
BasysPassiveRemotePeer >> prepareConnectionPool [
"
	no connections by default
"
	connectionPool maxActiveObjects: 0.
	connectionPool destroyer: [ :connection | 
		connectionPool fixMaxActiveObjects.
		connection close].
]
