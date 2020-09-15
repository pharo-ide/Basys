"
I am a TCP/IP server which serves a BasysNetwork.
I just pass incoming connections to the network instance.

You can create me by:

	server :=- BasysServer for: aBasysNetwork

And start the server using: 

	server start.
	
It will ask OS to assign free port for the server. Or you can specify concrete port number:

	BasysServer for: aBasysNetwork on: portNumber

Alternatively you can ask a network to start the server: 

	network startServer.
	network startServerOn: portNumber
	
To stop the server sende a message #stop. It will only close the listening socket and the incoming connection loop. 
It will not affect existing network connections. Network will continue work and should be closed separately if needed. 
The BasysServer only plays a role of network gateway allowing new connections to be added to the network. Stopping the server just closes this gateway.

Internal Representation and Key Implementation Points.

    Instance Variables
	network:		<BasysNetwork>
"
Class {
	#name : #BasysServer,
	#superclass : #TCPServer,
	#instVars : [
		'network'
	],
	#category : #Basys
}

{ #category : #'instance creation' }
BasysServer class >> for: aBasysNetwork [

	^self new
		network: aBasysNetwork
]

{ #category : #'instance creation' }
BasysServer class >> for: aBasysNetwork on: portNumber [

	^(self on: portNumber)
		network: aBasysNetwork
]

{ #category : #accessing }
BasysServer >> network [
	^ network
]

{ #category : #accessing }
BasysServer >> network: aBasysNetwork [
	network := aBasysNetwork
]

{ #category : #controlling }
BasysServer >> processNewConnection: clientSocket [

	| newPeer |
	newPeer := network addNewRemotePeer.
	
	[newPeer addNewConnectionOpenedRemotelyUsing: clientSocket] on: BasysTooManyConnections do: [ :err |
		clientSocket closeAndDestroy.
		network removeRemotePeer: newPeer ]
]
