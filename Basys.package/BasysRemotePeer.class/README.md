I represent  remote peer inside Basys network.
I maintain pool of connections which can be used to communicate with particular remote peer. 
I have two subclasses:
	- BasisActiveRemotePeer
		It can establish new connections by demand.
	- BasysPassiveRemotePeer
		It can't establish new connections. It only accepts connections from the outside. BasysServer is implemented for this. It accepts new connection and add it to corresponding passive remote peer.

Public API and Key Messages

- execute: aBlock 
	retrieves free connection from pool and execute given block with it. It can wait free connection if all in use or it can establish new one. It depends on type of peer: passive or active.
	
- sendDataPacket:   dataObject
	retrieves free connection from pool and send dataObject to it.

- close 
	closes all connections in pool

    Instance Variables
	address:		<TCPAddress>
	connectionPool:		<OPBasicPool>