operations
sendDataPacket: dataObject 

	self execute: [ :connection | connection sendDataPacket: dataObject ].
