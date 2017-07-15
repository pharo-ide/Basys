tests
testFailedRequestWhenRecursiveSpecialCommunicationFailure
 
	| remotePeer originalFailure |
	remotePeer := self connectToServerPeer.
	originalFailure := BasysCommunicationFailed new.
	
	[remotePeer execute:[:con | originalFailure signal ]]
		should raise: originalFailure