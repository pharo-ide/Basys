"
I am TCP server which serves Basys network.
I just pass incoming connections to network instance.

You can create me by 
	BasysServer for: aBasysNetwork
It will ask OS to assign free port for server. Or you can specify concrete port number:
	BasysServer for: aBasysNetwork on: portNumber

Alternatively you can ask a network to start the server: 
	network startServer.
	network startServerOn: portNumber

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

{ #category : #controlling }
BasysServer >> closeConnections [

	super closeConnections.
	
	network closeConnections
	
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
	newPeer := network addNewPeerForAcceptingConnections.
	
	newPeer acceptNewConnectionEstablishedBy: clientSocket
]

{ #category : #controlling }
BasysServer >> stop [

	super stop.
	
	network close
	
]
