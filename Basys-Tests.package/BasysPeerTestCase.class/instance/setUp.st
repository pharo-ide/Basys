running
setUp

	super setUp.
	
	network := Mock new.
	
	peer := self peerClass inside: network 