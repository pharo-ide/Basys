"
I am TCP server which serves Basys network.
I just pass incoming connections to network instance.

You can create me by 
	BasysServer for: aBasysNetwork on: portNumber

Or you can ask network to start me on port: 
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
	#category : 'Basys'
}

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
