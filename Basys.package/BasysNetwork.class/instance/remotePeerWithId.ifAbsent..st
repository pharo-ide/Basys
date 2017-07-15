accessing
remotePeerWithId: peerId ifAbsent: aBlock

	^remotePeers detect: [ :each | each id = peerId ] ifNone: aBlock