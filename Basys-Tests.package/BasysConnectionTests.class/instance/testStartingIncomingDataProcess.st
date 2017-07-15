tests
testStartingIncomingDataProcess
	
	connection stub incomingDataLoop 
		shouldBeSentInAnotherProcess;
		will: [ 
			Processor activeProcess should be: connection incomingDataProcess.
			Processor activeProcess terminate ].
	
	connection acceptIncomingData.
	20 milliSecond wait.
	
	connection incomingDataProcess should be isTerminated