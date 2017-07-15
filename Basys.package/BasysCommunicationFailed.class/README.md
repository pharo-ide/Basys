I am special failure to notify about errors during remotePeer #execute: method. I allow to make decision what to do: 
	- as default action I pass original error in state where participating connection is  not released (#execute: performed on borrowed connection)
	- #releaseConnectionAndPassError could be called on me to release connection and pass original error.
	
I am introduced generally to be able debug communication problems in one side and in other side to be able to transfer signalled errors on remote side of particular network implementation.

Public API and Key Messages

- releaseConnectionAndPassError 
 
Internal Representation and Key Implementation Points.

    Instance Variables
	reason:		<Error>