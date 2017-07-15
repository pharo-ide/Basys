I am TCP server which serves Basys network.
I just pass incoming connections to network instance.

You can create me by 
	BasysServer for: aBasysNetwork on: portNumber

Or you can ask network to start me on port: 
	network startServerOn: portNumber

Internal Representation and Key Implementation Points.

    Instance Variables
	network:		<BasysNetwork>