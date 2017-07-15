tests
testGettingExistedRemotePeerAtAddress

	| existedPeer remotePeer |
	existedPeer := BasysActiveRemotePeer inside: network at: #address.
	network addRemotePeer: existedPeer.

	remotePeer := network remotePeerAt: #address.
	
	remotePeer should be: existedPeer