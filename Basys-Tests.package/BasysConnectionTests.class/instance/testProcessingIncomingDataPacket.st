tests
testProcessingIncomingDataPacket
	
	[:process |
		[ connection processIncomingDataPacket ]
			should strictly satisfy: 
		[ (network receiveIncomingDataPacketFrom: remotePeer by: connection) willReturn: #dataPacket.
		(remotePeer prepareProcessingOf: #dataPacket) willReturn: process.
		process run ]

	] runWithMocks 