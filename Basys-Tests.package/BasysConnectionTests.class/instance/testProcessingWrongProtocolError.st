tests
testProcessingWrongProtocolError
	
	[
		[ connection incomingDataLoop ]
			should strictly satisfy: 
		[ (network receiveIncomingDataPacketFrom: remotePeer by: connection) 
				willRaise: BasysWrongProtocolError.
		socket close; destroy]

	] runWithMocks 