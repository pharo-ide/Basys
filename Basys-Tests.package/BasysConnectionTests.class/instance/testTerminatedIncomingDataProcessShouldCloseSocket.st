tests
testTerminatedIncomingDataProcessShouldCloseSocket
	
	connection stub incomingDataLoop 
		will: [ 10 seconds asDelay wait. #done].
	
	connection acceptIncomingData.
	20 milliSecond wait.
	connection incomingDataProcess terminate.

	connection should receive closeSocketSafely 