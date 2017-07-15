accessing
remotePeerAt: anAddress 
	| peer |
	^remotePeers detect: [ :each | each isBelongsTo: anAddress ] ifNone: [ 
		peer := BasysActiveRemotePeer inside: self at: anAddress.
		remotePeers add: peer.
		peer]