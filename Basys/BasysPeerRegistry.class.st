"
I am a thread safe registry of remote peers registered in BasysNetwork.

Internal Representation and Key Implementation Points.

    Instance Variables
	accessGuard:		<Mutex>
	remotePeers:		<OrderedCollection<BasysRemotePeer>>
"
Class {
	#name : #BasysPeerRegistry,
	#superclass : #Object,
	#instVars : [
		'accessGuard',
		'remotePeers'
	],
	#category : #Basys
}

{ #category : #accessing }
BasysPeerRegistry >> addRemotePeer: aRemotePeer [

	accessGuard critical: [ remotePeers add: aRemotePeer ].

	^aRemotePeer
]

{ #category : #controlling }
BasysPeerRegistry >> closeConnections [
	"This method only close existing connections. All peers are stayed working"
	
	accessGuard critical: [
		remotePeers do: [ :each | each closeConnections ]
	]
]

{ #category : #controlling }
BasysPeerRegistry >> closeRemotePeers [
	"Method closes all connected peers and their connections.
	As result all peers become closed and will forbid any remote communication
	When peer is closing it removes itself from the network. Therefore a copy is used for enumeration"
	| currentPeers |
	currentPeers := accessGuard critical: [ remotePeers copy ].
	currentPeers do: [ :each | each close ]
]

{ #category : #accessing }
BasysPeerRegistry >> connectionCount [

	^accessGuard critical: [ 
		remotePeers sumNumbers: [ :each | each connectionCount ]
	]
]

{ #category : #accessing }
BasysPeerRegistry >> identifyRemotePeer: aRemotePeer as: peerId [

	^accessGuard critical: [ 
		remotePeers 
			detect: [ :each | each id = peerId ] 
			ifFound: [:existingPeer | remotePeers remove: aRemotePeer ifAbsent: []. existingPeer ]
			ifNone:  [ aRemotePeer id: peerId ]
	]
]

{ #category : #initialization }
BasysPeerRegistry >> initialize [
	super initialize.
	
	accessGuard := Mutex new.
	remotePeers := OrderedCollection new
]

{ #category : #testing }
BasysPeerRegistry >> isEmpty [ 
	^remotePeers isEmpty "it is thread safe operation. No need for accessGuard"
]

{ #category : #printing }
BasysPeerRegistry >> printOn: aStream [
	super printOn: aStream.
	
	aStream 
		nextPut: $(;
		nextPutAll: self size;
		nextPut: $)
]

{ #category : #accessing }
BasysPeerRegistry >> remotePeerAt: anAddress ifAbsentRegister: peerBlock [

	^accessGuard critical: [ | newPeer |
		remotePeers detect: [ :each | each isBelongsTo: anAddress ] ifFound: [:found | ^found ].
		newPeer := peerBlock value.
		newPeer beActiveWith: anAddress.
		remotePeers add: newPeer.
		newPeer
	]
]

{ #category : #accessing }
BasysPeerRegistry >> remotePeers [
	^remotePeers
]

{ #category : #accessing }
BasysPeerRegistry >> removeRemotePeer: aRemotePeer [

	accessGuard critical: [ 
		remotePeers remove: aRemotePeer ifAbsent: [  ]
	]
]

{ #category : #accessing }
BasysPeerRegistry >> size [
	^remotePeers size
]
