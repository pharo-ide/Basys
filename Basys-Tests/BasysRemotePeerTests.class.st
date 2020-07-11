Class {
	#name : #BasysRemotePeerTests,
	#superclass : #BasysPeerTestCase,
	#instVars : [
		'peerAddress'
	],
	#category : #'Basys-Tests'
}

{ #category : #running }
BasysRemotePeerTests >> peerClass [
	^BasysRemotePeer
]

{ #category : #tests }
BasysRemotePeerTests >> testAddingNewConnectionOpenedRemotely [

	| connection pool |
	connection := Mock new.
	pool := Mock new.
	peer connectionPool: pool.
	peer stub newConnection willReturn: connection.
	
	peer addNewConnectionOpenedRemotelyUsing: #socket.

	[ connection socket: #socket.
	pool addConnection: connection.
	connection startIncomingDataProcess  ] should beDoneInOrder 
]

{ #category : #tests }
BasysRemotePeerTests >> testBelongsToOwnAddress [

	| actual |
	peer address: 'some address object' copy.
	
	actual := peer isBelongsTo: 'some address object' copy.
	
	actual should be: true
]

{ #category : #tests }
BasysRemotePeerTests >> testCanBeConfiguredWithMaxConnectionsLimit [
	
	peer maxConnections: 100.
	
	peer maxConnections should be: 100
]

{ #category : #tests }
BasysRemotePeerTests >> testClose [
	
	peer connectionPool stub.
	
	peer close.
	
	peer should be isClosed.
	peer connectionPool should receive close.
	network remotePeers should not include: peer. 
]

{ #category : #tests }
BasysRemotePeerTests >> testConnectionCount [
	
	peer maxConnections: 10.
	peer connectionPool addConnection: Mock new.
	peer connectionPool addConnection: Mock new.
	
	peer connectionCount should be: 2
]

{ #category : #tests }
BasysRemotePeerTests >> testConnectionCountWhenNothingExists [

	peer connectionCount should be: 0
]

{ #category : #tests }
BasysRemotePeerTests >> testCreatingNewConnection [

	| connection |
	connection := peer newConnection.
	
	connection should beInstanceOf: BasysConnection.
	connection network should be: network.
	connection remotePeer should be: peer
]

{ #category : #tests }
BasysRemotePeerTests >> testCreationActivePeerUsingAddress [
	
	peer := BasysRemotePeer inside: network at: #address.
	
	peer network should be: network.
	peer address should be: #address.
	peer connectionPool should beInstanceOf: BasysActiveConnectionPool.
	peer connectionPool remotePeer should be: peer
]

{ #category : #tests }
BasysRemotePeerTests >> testEnsureIdentityWhenItIsAlreadyIdentified [
	peer id: #peerId.
	
	peer ensureIdentity: #peerId.
	
	peer id should be: #peerId.
	network should not receive identifyRemotePeer: Any as: Any
]

{ #category : #tests }
BasysRemotePeerTests >> testEnsureIdentityWhenItIsAlreadyIdentifiedButAsAnotherPeer [

	peer id: #peerId.
		
	[peer ensureIdentity: #anotherPeerId] should raise: BasysIdentificationFailed.

	network should not receive identifyRemotePeer: Any as: Any
]

{ #category : #tests }
BasysRemotePeerTests >> testEnsureIdentityWhenItIsNotYetIdentified [
	peer id: nil.
	
	peer ensureIdentity: #peerId.
	
	network should receive identifyRemotePeer: peer as: #peerId.
	peer id should be: nil. "it should be performed by network above"
	
]

{ #category : #tests }
BasysRemotePeerTests >> testGettingLocalPeerId [

	network stub localPeerId willReturn: #localPeerId.
	
	peer localPeerId should be: #localPeerId
]

{ #category : #tests }
BasysRemotePeerTests >> testHasDefaultMaxConnectionsByDefault [
	
	peer maxConnections should beReturnedFrom: [ network maxConnectionsPerPeer ]
]

{ #category : #tests }
BasysRemotePeerTests >> testHasPassiveConnectionPoolByDefault [

	peer connectionPool should beInstanceOf: BasysPassiveConnectionPool.
	peer connectionPool remotePeer should be: peer
]

{ #category : #tests }
BasysRemotePeerTests >> testImportingConnectionsFromAnotherPeer [

	| anotherPeer |
	anotherPeer := BasysRemotePeer new.
	anotherPeer connectionPool stub.
	
	peer importConnectionsFrom: anotherPeer.
	
	anotherPeer connectionPool should receive migrateConnectionsInto: peer connectionPool
]

{ #category : #tests }
BasysRemotePeerTests >> testIsIdentified [
	
	peer id: nil.
	
	peer should not be isIdentified.
	
	peer id: #peerId.
	
	peer should be isIdentified.
]

{ #category : #tests }
BasysRemotePeerTests >> testMakingActivePeer [
	
	peer connectionPool stub.
	
	peer beActiveWith: #address.
	
	peer address should be: #address.
	peer connectionPool should receive beActive.
	peer should be isActive
]

{ #category : #tests }
BasysRemotePeerTests >> testMakingPassivePeer [
	
	peer connectionPool stub.
	
	peer bePassive.
	
	peer connectionPool should receive bePassive.
	peer should be isPassive
]

{ #category : #tests }
BasysRemotePeerTests >> testNotBelongsToDifferentAddress [

	| actual |
	peer address: 'some address object'.
	
	actual := peer isBelongsTo: 'different address'.
	
	actual should be: false
]

{ #category : #tests }
BasysRemotePeerTests >> testOpeningNewConnection [

	| activePool |
	activePool := Mock new.
	peer connectionPool: activePool.
		
	peer openNewConnection.
	
	activePool should receive openNewConnection
]

{ #category : #tests }
BasysRemotePeerTests >> testReceivingIncomingDataPackets [

	[:transporter |		
		[ (peer receiveIncomingDataPacketBy: #socket) should be: #result]
			should strictly satisfy: 
		[(network receiveIncomingDataPacketFrom: peer by: #socket) willReturn: #result].

	] runWithMocks 
]
