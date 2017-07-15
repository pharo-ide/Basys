accessing
connectionsCount
	remotePeers ifEmpty: [ ^0 ].
	
	^remotePeers sum: [ :each | each connectionsCount ]