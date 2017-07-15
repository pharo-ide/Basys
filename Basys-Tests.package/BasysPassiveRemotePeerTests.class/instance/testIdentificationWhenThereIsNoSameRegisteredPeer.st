tests
testIdentificationWhenThereIsNoSameRegisteredPeer

	[				
		[ (peer beIdentifiedAs: #peerId) should be: peer]
			should strictly satisfy: 
		[ (network remotePeerWithId: #peerId ifAbsent: Any)
				will: [ :arg1 :arg2 | arg2 value ] ].

		peer id should be: #peerId
	] runWithMocks 