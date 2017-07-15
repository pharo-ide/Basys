I represent process which handle connection incoming data in background. 
I can be created by network:
	network prepareProcessingOf: dataObject receivedFrom: aBasysRemotePeer
	
Public API and Key Messages

- run
	starts process

Internal Representation and Key Implementation Points.

    Instance Variables
	data:		<Object>
	network:		<BasysNetwork>
	realProcess:		<Process>
	senderPeer:		<BasysRemotePeer>