tests
testHasEmptyRemotePeersByDefault
	
	| actual |
	actual := network remotePeers.
	
	actual should be isEmpty