tests
testReceivingIncomingDataPackets

	[:transporter |		
		[ (peer receiveIncomingDataPacketBy: #socket) should be: #result]
			should strictly satisfy: 
		[(network receiveIncomingDataPacketFrom: peer by: #socket) willReturn: #result].

	] runWithMocks 