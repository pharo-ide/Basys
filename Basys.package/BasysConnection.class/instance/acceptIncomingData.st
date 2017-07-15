controlling
acceptIncomingData

	incomingDataProcess := [
		[self incomingDataLoop] ifCurtailed: [ self closeSocketSafely ]		
	] forkAt: processingPriority named: self printString.