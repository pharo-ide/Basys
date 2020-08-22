Class {
	#name : #BasysNetworkTests,
	#superclass : #TestCase,
	#instVars : [
		'network'
	],
	#category : 'Basys-Tests'
}

{ #category : #running }
BasysNetworkTests >> setUp [
	super setUp.
	
	network := BasysNetwork new.
]

{ #category : #tests }
BasysNetworkTests >> testAddingNewRemotePeer [

	| remotePeer |
	
	remotePeer := network addNewRemotePeer.
	
	remotePeer should beInstanceOf: BasysRemotePeer.
	remotePeer network should be: network.
	network remotePeers should include: remotePeer
]

{ #category : #tests }
BasysNetworkTests >> testClosing [

	| peer1 peer2 |
	peer1 := Mock new.
	peer2 := Mock new.
	network addRemotePeer: peer1; addRemotePeer: peer2.
		
	network close.
		
	peer1 should receive close.
	peer2 should receive close.
]

{ #category : #tests }
BasysNetworkTests >> testClosingConnections [

	| peer1 peer2 |
	peer1 := Mock new.
	peer2 := Mock new.
	network addRemotePeer: peer1; addRemotePeer: peer2.
		
	network closeConnections.
		
	peer1 should receive closeConnections.
	peer2 should receive closeConnections.
]

{ #category : #tests }
BasysNetworkTests >> testConnectionCount [

	| remotePeer1 remotePeer2 |
	remotePeer1 := Mock new.
	remotePeer1 stub connectionCount willReturn: 2.
	remotePeer2 := Mock new.
	remotePeer2 stub connectionCount willReturn: 5.
	
	network addRemotePeer: remotePeer1; addRemotePeer: remotePeer2.
		
	network connectionCount should be: 7
]

{ #category : #tests }
BasysNetworkTests >> testConnectionCountWhenNoRemotePeers [

	network connectionCount should be: 0
]

{ #category : #tests }
BasysNetworkTests >> testCreatingNewLocalPeer [

	| connection |
	connection := network newLocalPeer.
	
	connection should beInstanceOf: BasysLocalPeer.
	connection network should be: network
]

{ #category : #tests }
BasysNetworkTests >> testCreatingNewRemotePeer [

	| connection |
	connection := network newRemotePeer.
	
	connection should beInstanceOf: BasysRemotePeer.
	connection network should be: network
]

{ #category : #tests }
BasysNetworkTests >> testGettingExistingRemotePeerAtAddress [

	| existedPeer remotePeer |
	existedPeer := BasysRemotePeer inside: network at: #address.
	network addRemotePeer: existedPeer.

	remotePeer := network remotePeerAt: #address.
	
	remotePeer should be: existedPeer
]

{ #category : #tests }
BasysNetworkTests >> testGettingNewRemotePeerAtAddress [

	| existingPeer remotePeer |
	existingPeer := BasysRemotePeer inside: network at: #address.
	network addRemotePeer: existingPeer.

	remotePeer := network remotePeerAt: #newAddress.
	
	remotePeer should beInstanceOf: BasysRemotePeer.
	remotePeer network should be: network.
	remotePeer address should be: #newAddress.
	network remotePeers should include: remotePeer
]

{ #category : #tests }
BasysNetworkTests >> testHasDefaultConnectionTimeoutByDefault [

	network connectionTimeout should equal: BasysNetwork connectionTimeout.
	BasysNetwork connectionTimeout should not be: nil
]

{ #category : #tests }
BasysNetworkTests >> testHasDefaultMaxConnectionsByDefault [

	network maxConnectionsPerPeer should equal: BasysNetwork maxConnectionsPerPeer.
	BasysNetwork maxConnectionsPerPeer should not be: nil
]

{ #category : #tests }
BasysNetworkTests >> testHasEmptyRemotePeersByDefault [
	
	| actual |
	actual := network remotePeers.
	
	actual should be isEmpty
]

{ #category : #tests }
BasysNetworkTests >> testHasLocalPeerByDefault [
	
	| actual |
	actual := network localPeer.
	
	actual should beInstanceOf: BasysLocalPeer.
	actual network should be: network
]

{ #category : #tests }
BasysNetworkTests >> testIdentifyingActiveRemotePeerShouldConvertRegisteredPeerToBecomeActive [

	| registeredPeer newActivePeer |
	registeredPeer := BasysRemotePeer new.
	registeredPeer id: #peerId.
	network addRemotePeer: registeredPeer.
	newActivePeer := BasysRemotePeer new.
	newActivePeer beActiveWith: #address.	
		
	network identifyRemotePeer: newActivePeer as: #peerId.
	
	registeredPeer should be isActive.
	registeredPeer address should be: #address
]

{ #category : #tests }
BasysNetworkTests >> testIdentifyingPassiveRemotePeerShouldNotChangeRegisteredPeer [

	| registeredPeer newPassivePeer |
	registeredPeer := BasysRemotePeer new.
	registeredPeer id: #peerId.
	network addRemotePeer: registeredPeer.
	newPassivePeer := BasysRemotePeer new.
		
	network identifyRemotePeer: newPassivePeer as: #peerId.
	
	registeredPeer should not be isActive
]

{ #category : #tests }
BasysNetworkTests >> testIdentifyingRemotePeerShouldConvertItIntoRegisteredPeer [

	| registeredPeer newPeer |
	registeredPeer := BasysRemotePeer new.
	registeredPeer id: #peerId.
	network addRemotePeer: registeredPeer.
	newPeer := BasysRemotePeer new.
	network addRemotePeer: newPeer.
		
	network identifyRemotePeer: newPeer as: #peerId.
	
	newPeer should be: registeredPeer
]

{ #category : #tests }
BasysNetworkTests >> testIdentifyingRemotePeerShouldMigrateAllConnectionsIntoRegisteredPeer [

	| registeredPeer newPeer newPeerConnections |
	registeredPeer := BasysRemotePeer new.
	registeredPeer id: #peerId.
	network addRemotePeer: registeredPeer.
	newPeer := BasysRemotePeer new.
	newPeerConnections := newPeer connectionPool.
	newPeerConnections stub.
		
	network identifyRemotePeer: newPeer as: #peerId.
	
	newPeerConnections should receive migrateConnectionsInto: registeredPeer connectionPool
]

{ #category : #tests }
BasysNetworkTests >> testIdentifyingRemotePeerWhenItWasAlreadyRegisteredShouldRemoveItFromNetwork [

	| registeredPeer newPeer |
	registeredPeer := BasysRemotePeer new.
	registeredPeer id: #peerId.
	network addRemotePeer: registeredPeer.
	newPeer := BasysRemotePeer new.
	network addRemotePeer: newPeer.
		
	network identifyRemotePeer: newPeer as: #peerId.
	
	network remotePeers should equal: { registeredPeer }
]

{ #category : #tests }
BasysNetworkTests >> testIdentifyingRemotePeerWhenItWasNotYetRegistered [

	| remotePeer |
	remotePeer := BasysRemotePeer new.
	
	network identifyRemotePeer: remotePeer as: #peerId.
	
	remotePeer id should be: #peerId 
]

{ #category : #tests }
BasysNetworkTests >> testIdentifyingRemotePeerWhenRegisteredPeerDoesNotAllowMoreConnections [

	| registeredPeer newPeer newPeerConnections |
	registeredPeer := BasysRemotePeer new.
	registeredPeer id: #peerId.
	network addRemotePeer: registeredPeer.
	newPeer := BasysRemotePeer new.
	newPeerConnections := newPeer connectionPool.
	(newPeerConnections stub migrateConnectionsInto: Any) willRaise: BasysTooManyConnections new.
		
	network identifyRemotePeer: newPeer as: #peerId.
	
	newPeerConnections should receive clear.
	newPeer should be: registeredPeer
]

{ #category : #tests }
BasysNetworkTests >> testRemoveRemotePeer [

	network addRemotePeer: #remotePeer.
	
	network removeRemotePeer: #remotePeer.
	
	network remotePeers should not include: #remotePeer
]

{ #category : #tests }
BasysNetworkTests >> testShouldFollowDefaultConnectionTimeoutChangesWhenInstanceIsNotConfigured [

	| current |
	network connectionTimeout should equal: BasysNetwork connectionTimeout.
	current := BasysNetwork connectionTimeout.
	[ 
		BasysNetwork connectionTimeout: 1000 seconds.
		network connectionTimeout should equal: BasysNetwork connectionTimeout.
	] ensure: [ BasysNetwork connectionTimeout: current ]
]
