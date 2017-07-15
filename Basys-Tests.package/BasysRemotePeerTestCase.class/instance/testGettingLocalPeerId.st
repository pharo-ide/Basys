tests
testGettingLocalPeerId

	network stub localPeerId willReturn: #localPeerId.
	
	peer localPeerId should be: #localPeerId