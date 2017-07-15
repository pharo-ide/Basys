tests
testClosing
	
	connection stub incomingDataLoop 
		will: [ 10 seconds asDelay wait. #done].
	
	connection acceptIncomingData.
	20 milliSecond wait.
	connection close.
	20 milliSecond wait.

	connection incomingDataProcess should be isTerminated.
	connection should receive closeSocketSafely.