controlling
beIdentifiedAs: peerId
	
	| registeredPeer |
	registeredPeer := network remotePeerWithId: peerId ifAbsent: [ 
		id := peerId. ^self ].
	
	self == registeredPeer ifTrue: [ self error: 'Should not happen' ].
	
	registeredPeer importConnectionsFrom: connectionPool.
	network removeRemotePeer: self.
	"following become required because imported connections 
	could hold old peer instance on incoming process stack"
	self becomeForward: registeredPeer.
	^registeredPeer 