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
BasysNetworkTests >> testAddingNewPassivePeer [

	| remotePeer |
	
	remotePeer := network addNewPassivePeer.
	
	remotePeer should beInstanceOf: BasysPassiveRemotePeer.
	remotePeer network should be: network.
	network remotePeers should include: remotePeer
]

{ #category : #tests }
BasysNetworkTests >> testClosing [

	[:peer1 :peer2 |
		network addRemotePeer: peer1; addRemotePeer: peer2.
		
		network close.
		
		peer1 should receive close.
		peer2 should receive close.
		network remotePeers should be isEmpty	
			
	] runWithMocks 
]

{ #category : #tests }
BasysNetworkTests >> testClosingConnections [

	[:peer1 :peer2 |
		network addRemotePeer: peer1; addRemotePeer: peer2.
		
		network closeConnections.
		
		peer1 should receive closeConnections.
		peer2 should receive closeConnections
			
	] runWithMocks 
]

{ #category : #tests }
BasysNetworkTests >> testConnectionsCount [

	| remotePeer1 remotePeer2 |
	remotePeer1 := Mock new.
	remotePeer1 stub connectionsCount willReturn: 2.
	remotePeer2 := Mock new.
	remotePeer2 stub connectionsCount willReturn: 5.
	
	network addRemotePeer: remotePeer1; addRemotePeer: remotePeer2.
		
	network connectionsCount should be: 7
]

{ #category : #tests }
BasysNetworkTests >> testConnectionsCountWhenNoRemotePeers [

	network connectionsCount should be: 0
]

{ #category : #tests }
BasysNetworkTests >> testGettingExistedRemotePeerAtAddress [

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
BasysNetworkTests >> testGettingPeerWithIdWhenItExists [

	| remotePeer actual |
	remotePeer := BasysPassiveRemotePeer new id: 1.
	network addRemotePeer: remotePeer.
	
	actual := network remotePeerWithId: 1 ifAbsent: [  ].
	
	actual should be: remotePeer
]

{ #category : #tests }
BasysNetworkTests >> testGettingPeerWithIdWhenItNotExists [

	| actual |
	
	actual := network remotePeerWithId: 1 ifAbsent: [ #result ].
	
	actual should be: #result
]

{ #category : #tests }
BasysNetworkTests >> testHasDefaultConnectionTimeoutByDefault [

	network connectionTimeout should equal: BasysNetwork defaultConnectionTimeout.
	BasysNetwork defaultConnectionTimeout should not be: nil
]

{ #category : #tests }
BasysNetworkTests >> testHasDefaultMaxConnectionsCountPerPeerByDefault [

	network maxConnectionsCountPerPeer should equal: BasysNetwork defaultMaxConnectionsCountPerPeer.
	BasysNetwork defaultMaxConnectionsCountPerPeer should not be: nil
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
BasysNetworkTests >> testIdentifyingRemotePeerWhenItWasAlreadyRegisteredShouldRemoveItFromNetwork [

	| registeredPeer newPeer |
	registeredPeer := BasysRemotePeer new.
	registeredPeer id: #peerId.
	newPeer := BasysRemotePeer new.
	network addRemotePeer: registeredPeer.
	network addRemotePeer: newPeer.
		
	network identifyRemotePeer: newPeer as: #peerId.
	
	network remotePeers should not include: newPeer
]

{ #category : #tests }
BasysNetworkTests >> testIdentifyingRemotePeerWhenItWasNotYetRegistered [

	| remotePeer |
	remotePeer := BasysRemotePeer new.
	
	network identifyRemotePeer: remotePeer as: #peerId.
	
	remotePeer id should be: #peerId 
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
	network connectionTimeout should equal: BasysNetwork defaultConnectionTimeout.
	current := BasysNetwork defaultConnectionTimeout.
	[ 
		BasysNetwork defaultConnectionTimeout: 1000 seconds.
		network connectionTimeout should equal: BasysNetwork defaultConnectionTimeout.
	] ensure: [ BasysNetwork defaultConnectionTimeout: current ]
]
