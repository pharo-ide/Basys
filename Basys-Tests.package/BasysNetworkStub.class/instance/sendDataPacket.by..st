operations
sendDataPacket: dataObject by: aBasysConnection
	| stream |
	
	stream := aBasysConnection outputStream.
	
	stream nextPutAll: dataObject asString; crlf; flush.
	
"	Transcript show: 'new data sent: ', dataObject printString ; cr"