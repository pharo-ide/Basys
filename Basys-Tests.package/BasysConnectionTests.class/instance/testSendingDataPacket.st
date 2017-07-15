tests
testSendingDataPacket
	
	[
		[ connection sendDataPacket: #dataPacket ]
			should strictly satisfy: 
		[ network sendDataPacket: #dataPacket by: connection ]

	] runWithMocks 