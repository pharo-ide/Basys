tests
testGettingPeerWithIdWhenItNotExists

	| actual |
	
	actual := network remotePeerWithId: 1 ifAbsent: [ #result ].
	
	actual should be: #result