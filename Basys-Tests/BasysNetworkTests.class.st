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
BasysNetworkTests >> testAddingNewPeerForAcceptingConnections [

	| remotePeer |
	
	remotePeer := network addNewPeerForAcceptingConnections.
	
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
BasysNetworkTests >> testCreationNewConnection [
	
	| actual |
	actual := network createConnectionOn: #socket.
	
	actual should beInstanceOf: BasysConnection.
	actual network should be: network.
	actual socket should be: #socket
]

{ #category : #tests }
BasysNetworkTests >> testGettingExistedRemotePeerAtAddress [

	| existedPeer remotePeer |
	existedPeer := BasysActiveRemotePeer inside: network at: #address.
	network addRemotePeer: existedPeer.

	remotePeer := network remotePeerAt: #address.
	
	remotePeer should be: existedPeer
]

{ #category : #tests }
BasysNetworkTests >> testGettingNewRemotePeerAtAddress [

	| existedPeer remotePeer |
	existedPeer := BasysActiveRemotePeer inside: network at: #address.
	network addRemotePeer: existedPeer.

	remotePeer := network remotePeerAt: #newAddress.
	
	remotePeer should beInstanceOf: BasysActiveRemotePeer.
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
BasysNetworkTests >> testRemoveRemotePeer [

	network addRemotePeer: #remotePeer.
	
	network removeRemotePeer: #remotePeer.
	
	network remotePeers should not include: #remotePeer
]
