running
setUp
	super setUp.
	
	forkedProcesses := OrderedCollection new.
	
	serverSideNetwork := self networkClass new. 	
	server network: serverSideNetwork .	
	server start	.
		
	clientSideNetwork := self networkClass new