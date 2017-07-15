tests
testFailedRequestAtTheEndShouldPassErrorAndNotFreeGivenConnection
 
	| remotePeer errorCatched connection |
	remotePeer := self connectToServerPeer.
	errorCatched := false. 
	
	[
		[remotePeer execute:[:con | connection := con. 1/0 ]] 
			on: BasysCommunicationFailed do: [ :err | err defaultAction  ]
	]
		on: ZeroDivide do: [:err | errorCatched := true.
			remotePeer freeConnectionsCount should be: 0].
		
	errorCatched should be: true