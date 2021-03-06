Class {
	#name : #BasysRemotePeerTests,
	#superclass : #BasysPeerTestCase,
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
BasysRemotePeerTests >> testClosingConnections [
	
	peer connectionPool stub.
	
	peer closeConnections.
	
	peer connectionPool should receive clear
]

{ #category : #tests }
BasysRemotePeerTests >> testClosingShouldCloseConnectionPool [
	
	peer connectionPool stub.
	
	peer close.
	
	peer connectionPool should receive close.
	peer should be isClosed
]

{ #category : #tests }
BasysRemotePeerTests >> testClosingShouldMakePeerClosed [
	
	peer close.
	
	peer should be isClosed
]

{ #category : #tests }
BasysRemotePeerTests >> testClosingShouldRemovePeerFromNetwork [
	
	peer close.
	
	network should receive removeRemotePeer: peer
]

{ #category : #tests }
BasysRemotePeerTests >> testConnectionCount [
	
	peer connectionPool stub.
	
	peer connectionCount should beReturnedFrom: [ peer connectionPool openSize ]
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
BasysRemotePeerTests >> testFreeConnectionCount [
	
	peer connectionPool stub.
	
	peer freeConnectionCount should beReturnedFrom: [ peer connectionPool freeSize ]
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
BasysRemotePeerTests >> testRemoveClosedConnection [

	| connection |
	connection := Mock new.
	peer connectionPool: Mock new.
	peer removeClosedConnection: connection.
	
	peer connectionPool should receive removeClosedConnection: connection
]

{ #category : #tests }
BasysRemotePeerTests >> testTryingObjectSendIgnoresClosedPeerError [
	
	| wasSent |
	peer stub isConnected willReturn: true.
	peer close.
	
	wasSent := peer trySendObjectIfConnected: #object.
	
	wasSent should be: false.
	peer should receive sendObject: #object
]

{ #category : #tests }
BasysRemotePeerTests >> testTryingObjectSendIgnoresConnectionTimeout [
	
	| wasSent |
	peer stub isConnected willReturn: true.
	(peer stub sendObject: #object) willRaise: ConnectionTimedOut new.
	
	wasSent := peer trySendObjectIfConnected: #object.
	
	wasSent should be: false.
	peer should receive sendObject: #object
]

{ #category : #tests }
BasysRemotePeerTests >> testTryingObjectSendIgnoresIdentificationError [
	
	| wasSent |
	peer stub isConnected willReturn: true.
	(peer stub sendObject: #object) willRaise: BasysIdentificationFailed new.
	
	wasSent := peer trySendObjectIfConnected: #object.
	
	wasSent should be: false.
	peer should receive sendObject: #object
]

{ #category : #tests }
BasysRemotePeerTests >> testTryingObjectSendIgnoresNoConnectionError [
	
	| wasSent |
	peer stub isConnected willReturn: true.
	(peer stub sendObject: #object) willRaise: BasysNoConnection new.
	
	wasSent := peer trySendObjectIfConnected: #object.
	
	wasSent should be: false.
	peer should receive sendObject: #object
]

{ #category : #tests }
BasysRemotePeerTests >> testTryingObjectSendShouldSignalUnexpectedProblems [
	
	| unexpectedProblem |
	peer stub isConnected willReturn: true.
	unexpectedProblem := Error new.
	(peer stub sendObject: Any) willRaise: unexpectedProblem.
		
	[peer trySendObjectIfConnected: #object] should raise: unexpectedProblem
]

{ #category : #tests }
BasysRemotePeerTests >> testTryingObjectSendWhenNoConnectionAvailable [
	
	| wasSent |
	peer stub isConnected willReturn: false.
	
	wasSent := peer trySendObjectIfConnected: #object.
	
	wasSent should be: false.	
	peer should not receive sendObject: Any
]

{ #category : #tests }
BasysRemotePeerTests >> testTryingObjectSendWhenThereIsAvailableConnection [
	
	| wasSent |
	peer stub isConnected willReturn: true.
	(peer stub sendObject: #object) will: [ #done ].
	
	wasSent := peer trySendObjectIfConnected: #object.
	
	wasSent should be: true.	
	peer should receive sendObject: #object
]

{ #category : #tests }
BasysRemotePeerTests >> testWaitingConnection [

	| pool |
	pool := Mock new.
	peer connectionPool: pool.
		
	peer waitConnection.
	
	pool should receive waitOpenedConnection
]
