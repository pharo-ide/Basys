I represent connection with remote peer inside Basys network.
I run process with incoming data loop which receive new data and run it processing asynchronously. 
Socket variable represents phisical connection to remote peer.  It is passed as argument to network to perform concrete operations: reading incoming data, processing it or sending new data.

Public API and Key Messages

- sendDataPacket:   dataObject
	sends dataObject to remote peer.
- acceptIncomingData 
	runs incoming data loop in separate process 
- close
	terminates incoming data process and closes socket

Instances are created by:
	BasysConnection inside: aBasysNetwork on: aSocket
 
Internal Representation and Key Implementation Points.

    Instance Variables
	incomingDataProcess:		<Process>
	network:		<BasysNetwork>
	processingPriority:		<Integer>	declares priority for incoming data process.
	remotePeer:		<BasysRemotePeer>
	socket:		<Socket>	represent phisical connection to remote peer.