controlling
closeConnections
	"This method only close existing connections. All peers are stayed working"
	remotePeers do: [ :each | each closeConnections ]