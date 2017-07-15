tests
testGettingNewRemotePeerAtAddress

	| existedPeer remotePeer |
	existedPeer := BasysActiveRemotePeer inside: network at: #address.
	network addRemotePeer: existedPeer.

	remotePeer := network remotePeerAt: #newAddress.
	
	remotePeer should beInstanceOf: BasysActiveRemotePeer.
	remotePeer network should be: network.
	remotePeer address should be: #newAddress.
	network remotePeers should include: remotePeer