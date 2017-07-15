private
establishNewConnectionWithoutPooling
"
	First I establish new connection to server. Then I should identify localPeer on server side. So server can add new connection to peer which represents it. With identification server will have single remote peer with many pooled connections which points to my (client) localPeer. But without identification server will always has separate peer for any connection.
"
	
	| connection receivedRemotePeerId |
	connection := network establishNewConnectionTo: address.
	connection remotePeer: self.
	connection acceptIncomingData.
	[receivedRemotePeerId := network identifyLocalPeerOn: connection.
	self assignId: receivedRemotePeerId receivedFrom: connection] on: Error do: [:err | 
		connection close.
		err pass].
			
	^connection