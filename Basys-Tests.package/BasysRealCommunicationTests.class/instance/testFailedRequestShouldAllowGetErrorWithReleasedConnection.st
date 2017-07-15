tests
testFailedRequestShouldAllowGetErrorWithReleasedConnection
 
	| remotePeer errorCatched connection |
	remotePeer := self connectToServerPeer.
	errorCatched := false. 
	
	[
		[remotePeer execute:[:con | connection := con. 1/0 ]] 
			on: BasysCommunicationFailed do: [ :err | err releaseConnectionAndPassError  ]
	]
		on: ZeroDivide do: [:err | errorCatched := true.
			remotePeer freeConnectionsCount should be: 1].
		
	errorCatched should be: true