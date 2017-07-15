initialization
initialize
	super initialize.
	
	communicationLibrary := TCPPharoNetworkLibrary.
	connectionTimeout := 45 milliSeconds.
	processingPriority := Processor userBackgroundPriority.
	localPeer := BasysLocalPeer inside: self.
	remotePeers := OrderedCollection new.
	