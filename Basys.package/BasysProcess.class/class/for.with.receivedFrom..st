instance creation
for: aNetwork with: dataObject receivedFrom: aRemotePeer
	^self new 
		network: aNetwork;
		data: dataObject;
		senderPeer: aRemotePeer 