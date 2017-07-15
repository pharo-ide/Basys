operations
establishNewConnectionTo: anAddress

	| socket |
	socket := communicationLibrary openConnectionTo: anAddress timeout: connectionTimeout.
	 
	^self createConnectionOn: socket