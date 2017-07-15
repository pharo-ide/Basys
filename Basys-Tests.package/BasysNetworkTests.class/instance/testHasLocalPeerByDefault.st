tests
testHasLocalPeerByDefault
	
	| actual |
	actual := network localPeer.
	
	actual should beInstanceOf: BasysLocalPeer.
	actual network should be: network