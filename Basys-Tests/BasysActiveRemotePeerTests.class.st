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
		connection acceptIncomingData.
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
		connection acceptIncomingData.
		(network identifyLocalPeerOn: connection) willReturn: #remotePeerId.
		(network remotePeerWithId: #remotePeerId ifAbsent: Any) willReturn: existedPeer.
		existedPeer addNewConnection: connection.
		existedPeer becomeActiveToReplaceSamePeer: peer.
		connectionPool objectToPool: connection].
	
		peer id should be: nil.
	] runWithMocks 
]
