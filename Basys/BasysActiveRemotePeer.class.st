"
I represent remote peer inside Basys network which knows how to establish new connections to remote side. ""Active"" in my name means that I can initiate new conections by demand.
I can be treated as peer which represents server on client. But when rserver can connect to client too then this definition becomes not valid.

I can be created by 
	BasysActiveRemotePeer inside: aBasysNetwork at: aTCPAddress 
But users should ask me from network  by 
	network remotePeerAt: anAddress

When I am created I prepare my connection pool to establish new connections if others are busy or not exists
"
Class {
	#name : #BasysActiveRemotePeer,
	#superclass : #BasysRemotePeer,
	#category : 'Basys'
}

{ #category : #'instance creation' }
BasysActiveRemotePeer class >> inside: aBasysNatwork at: anAddress [

	^(self inside: aBasysNatwork)
		address: anAddress
		
]

{ #category : #private }
BasysActiveRemotePeer >> assignId: peerId receivedFrom: aBasysConnection [

	| registeredPeer |
	self isIdentified ifTrue: [ 
		id = peerId ifFalse: [BasysIdentificationFailed signal].
		^self 
	].

	registeredPeer := network remotePeerWithId: peerId ifAbsent: [^id := peerId ]. 

	registeredPeer addNewConnection: aBasysConnection.
	registeredPeer becomeActiveToReplaceSamePeer: self.
	"it will replace all my references by registeredPeer. And it change registeredPeer class to be active"
]

{ #category : #communication }
BasysActiveRemotePeer >> establishNewConnection [

	| connection |
	connection := self establishNewConnectionWithoutPooling.
	connectionPool objectToPool: connection
]

{ #category : #private }
BasysActiveRemotePeer >> establishNewConnectionWithoutPooling [
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
]

{ #category : #initialization }
BasysActiveRemotePeer >> prepareConnectionPool [
"
	connections will be established by demand
"
	connectionPool creator: [ self establishNewConnectionWithoutPooling ].
]
