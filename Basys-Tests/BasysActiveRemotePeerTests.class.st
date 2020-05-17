Class {
	#name : #BasysActiveRemotePeerTests,
	#superclass : #BasysRemotePeerTestCase,
	#category : 'Basys-Tests'
}

{ #category : #running }
BasysActiveRemotePeerTests >> peerClass [ 
	^BasysActiveRemotePeer 
]

{ #category : #tests }
BasysActiveRemotePeerTests >> testEstablishingNewConnection [

	[:connection :connectionPool |
		peer connectionPool: connectionPool.
		
		[ peer establishNewConnection]
			should strictly satisfy: 
		[(network establishNewConnectionTo: peerAddress) willReturn: connection.
		connection remotePeer: peer.
		connection startIncomingDataProcess.
		(network identifyLocalPeerOn: connection) willReturn: #remotePeerId.
		(network remotePeerWithId: #remotePeerId ifAbsent: Any) will: [:arg1 :arg2 | arg2 value].
		connectionPool objectToPool: connection].
	
		peer id should be: #remotePeerId.
	] runWithMocks 
]

{ #category : #tests }
BasysActiveRemotePeerTests >> testEstablishingNewConnectionWhenIdentificationFailed [

	[:connection :connectionPool |
		peer connectionPool: connectionPool.
		(network stub establishNewConnectionTo: peerAddress) willReturn: connection.
		(network stub identifyLocalPeerOn: connection) willRaise: Error.
				
		[peer establishNewConnection] should fail.

		connection should receive close
	] runWithMocks 
]

{ #category : #tests }
BasysActiveRemotePeerTests >> testEstablishingNewConnectionWhenReceivedPeerIdIsDiffersFromExisted [

	[:connection :connectionPool |
		peer connectionPool: connectionPool.
		peer id: #existedPeerId.
		(network stub establishNewConnectionTo: peerAddress) willReturn: connection.
		(network stub identifyLocalPeerOn: connection) willReturn: #differentPeerId.
	
		[peer establishNewConnection] should raise: BasysIdentificationFailed.
	
		connection should receive close.	
	] runWithMocks 
]

{ #category : #tests }
BasysActiveRemotePeerTests >> testEstablishingNewConnectionWhenSamePeerIsAlreadyRegistered [

	[:connection :connectionPool :existedPeer |
		peer connectionPool: connectionPool.
		
		[ peer establishNewConnection]
			should strictly satisfy: 
		[(network establishNewConnectionTo: peerAddress) willReturn: connection.
		connection remotePeer: peer.
		connection startIncomingDataProcess.
		(network identifyLocalPeerOn: connection) willReturn: #remotePeerId.
		(network remotePeerWithId: #remotePeerId ifAbsent: Any) willReturn: existedPeer.
		existedPeer addNewConnection: connection.
		existedPeer becomeActiveToReplaceSamePeer: peer.
		connectionPool objectToPool: connection].
	
		peer id should be: nil.
	] runWithMocks 
]

{ #category : #tests }
BasysActiveRemotePeerTests >> testIdentifyingFirstConnection [
	(network stub identifyLocalPeerOn: #connection) willReturn: #peerId.
	(network stub remotePeerWithId: #peerId ifAbsent: Any) will: [ :id :block | block value ].
	
	peer identifyConnection: #connection.
	
	peer id should be: #peerId
]

{ #category : #tests }
BasysActiveRemotePeerTests >> testIdentifyingNewConnectionWhenAlreadyIdentified [
	(network stub identifyLocalPeerOn: #connection) willReturn: #peerId.
	peer id: #peerId.
	
	peer identifyConnection: #connection.
	
	peer id should be: #peerId.
	network should not receive remotePeerWithId: Any ifAbsent: Any
]

{ #category : #tests }
BasysActiveRemotePeerTests >> testIdentifyingNewConnectionWhenItBelongsToExistingPassivePeer [
	| existingPeer |
	existingPeer := Mock new.
	(network stub identifyLocalPeerOn: #connection) willReturn: #peerId.
	(network stub remotePeerWithId: #peerId ifAbsent: Any) willReturn: existingPeer.
	
	peer identifyConnection: #connection.
	
	existingPeer should receive becomeActiveToReplaceSamePeer: peer.
	
	
]

{ #category : #tests }
BasysActiveRemotePeerTests >> testIdentifyingNewConnectionWhenItIsFromAnotherPeerId [
	(network stub identifyLocalPeerOn: #connection) willReturn: #anotherPeerId.
	peer id: #peerId.
	
	[peer identifyConnection: #connection] should raise: BasysIdentificationFailed.
	network should not receive remotePeerWithId: Any ifAbsent: Any
	
]
