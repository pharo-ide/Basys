Class {
	#name : #BasysActiveRemotePeerTests,
	#superclass : #BasysRemotePeerTestCase,
	#category : 'Basys-Tests'
}

{ #category : #running }
BasysActiveRemotePeerTests >> peerClass [ 
	^BasysRemotePeer 
]

{ #category : #tests }
BasysActiveRemotePeerTests >> testCanBeConfiguredWithMaxConnectionsCount [
	
	peer maxConnectionsCount: 100.
	
	peer maxConnectionsCount should be: 100
]

{ #category : #tests }
BasysActiveRemotePeerTests >> testConnectionsCount [
	
	peer maxConnectionsCount: 10.
	peer connectionPool objectToPool: Mock new.
	peer connectionPool objectToPool: Mock new.
	
	peer connectionsCount should be: 2
]

{ #category : #tests }
BasysActiveRemotePeerTests >> testCreationActivePeerUsingAddress [
	
	peer := BasysRemotePeer inside: network at: #address.
	
	peer network should be: network.
	peer address should be: #address.
	peer connectionPool should beInstanceOf: BasysActiveConnectionPool.
	peer connectionPool remotePeer should be: peer
]

{ #category : #tests }
BasysActiveRemotePeerTests >> testEnsureIdentityWhenItIsAlreadyIdentified [
	peer id: #peerId.
	
	peer ensureIdentity: #peerId.
	
	peer id should be: #peerId.
	network should not receive identifyRemotePeer: Any as: Any
]

{ #category : #tests }
BasysActiveRemotePeerTests >> testEnsureIdentityWhenItIsAlreadyIdentifiedButAsAnotherPeer [

	peer id: #peerId.
		
	[peer ensureIdentity: #anotherPeerId] should raise: BasysIdentificationFailed.

	network should not receive identifyRemotePeer: Any as: Any
]

{ #category : #tests }
BasysActiveRemotePeerTests >> testEnsureIdentityWhenItIsNotYetIdentified [
	peer id: nil.
	
	peer ensureIdentity: #peerId.
	
	network should receive identifyRemotePeer: peer as: #peerId.
	peer id should be: nil. "it should be performed by network above"
	
]

{ #category : #tests }
BasysActiveRemotePeerTests >> testHasDefaultMaxConnectionsCount [
	
	peer maxConnectionsCount should beReturnedFrom: [ network maxConnectionsCountPerPeer ]
]

{ #category : #tests }
BasysActiveRemotePeerTests >> testHasPassiveConnectionPoolByDefault [

	peer connectionPool should beInstanceOf: BasysPassiveConnectionPool.
	peer connectionPool remotePeer should be: peer
]

{ #category : #tests }
BasysActiveRemotePeerTests >> testMakingActivePeer [
	
	peer connectionPool stub.
	
	peer beActiveWith: #address.
	
	peer address should be: #address.
	peer connectionPool should receive beActive.
	peer should be isActive
]

{ #category : #tests }
BasysActiveRemotePeerTests >> testMakingPassivePeer [
	
	peer connectionPool stub.
	
	peer bePassive.
	
	peer connectionPool should receive bePassive.
	peer should be isPassive
]

{ #category : #tests }
BasysActiveRemotePeerTests >> testOpeningNewConnection [

	| activePool |
	activePool := Mock new.
	peer connectionPool: activePool.
		
	peer openNewConnection.
	
	activePool should receive openNewConnection
]
