running
waitServerSidePeer
	
	self waitUntil: [ serverSideNetwork remotePeers notEmpty ].
	^serverSideNetwork remotePeers anyOne