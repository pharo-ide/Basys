controlling
close
	"This method to really close all connected peers with existing connections.
	 As result all peers become closed and will forbid any remote communication
	When peer is closing it removes itself from network. That's why we enumerate on copy"
	remotePeers copy do: [ :each | each close ].
	remotePeers removeAll