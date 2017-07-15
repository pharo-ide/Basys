controlling
processIncomingDataPacket

	| dataPacket process |
	
	dataPacket := network receiveIncomingDataPacketFrom: remotePeer by: self.
	process := remotePeer prepareProcessingOf: dataPacket.
	
	process run.