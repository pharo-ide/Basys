tests
testFailedRequestShouldSignalSpecialCommunicationFailure
 
	| remotePeer errorCatched connection failure |
	remotePeer := self connectToServerPeer.
	errorCatched := false. 
	
	[remotePeer execute:[:con | connection := con. 1/0 ]]
		on: BasysCommunicationFailed do: [:err | errorCatched := true.
			failure := err.
			remotePeer freeConnectionsCount should be: 0].
		
	errorCatched should be: true.
	failure reason should beInstanceOf: ZeroDivide 
	