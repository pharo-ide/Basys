operations
receiveIncomingDataPacketFrom: aRemotePeer by: aBasysConnection
	| stream |
	
	stream := aBasysConnection inputStream.
	stream timeout: waitingDataTimeout asMilliSeconds / 1000.0.
	stream ascii.
	^stream nextLine