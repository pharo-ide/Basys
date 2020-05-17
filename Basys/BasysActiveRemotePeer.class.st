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

{ #category : #communication }
BasysActiveRemotePeer >> establishNewConnection [

	| connection |
	connection := self newConnection.
	connection open.
	connectionPool objectToPool: connection
]

{ #category : #private }
BasysActiveRemotePeer >> identifyConnection: aConnection [
	| receivedPeerId registeredPeer |
	receivedPeerId := network identifyLocalPeerOn: aConnection. 
	self isIdentified ifTrue: [ 
		id = receivedPeerId ifFalse: [BasysIdentificationFailed signal].
		^self ].

	registeredPeer := network remotePeerWithId: receivedPeerId ifAbsent: [
		id := receivedPeerId. 
		^self ]. 

	registeredPeer becomeActiveToReplaceSamePeer: self.
	"It will replace all my references by registeredPeer. And it will change the class of registeredPeer to be active"
]

{ #category : #private }
BasysActiveRemotePeer >> newConnection [
	^BasysConnection with: self inside: network
]

{ #category : #initialization }
BasysActiveRemotePeer >> prepareConnectionPool [
"
	connections will be established by demand
"
	connectionPool creator: [ self newConnection ].
]
