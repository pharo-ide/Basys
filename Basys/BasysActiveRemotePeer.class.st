"
I represent remote peer inside Basys network which knows how to establish new connections to remote side. ""Active"" in my name means that I can initiate new conections by demand.
I can be treated as peer which represents server on client. But when rserver can connect to client too then this definition becomes not valid.

I can be created by 
	BasysActiveRemotePeer inside: aBasysNetwork at: aTCPAddress 
But users should ask me from network  by 
	network remotePeerAt: anAddress

When I am created I prepare my connection pool to establish new connections if others are busy or not exists
"
Class {
	#name : #BasysActiveRemotePeer,
	#superclass : #BasysRemotePeer,
	#category : 'Basys'
}
