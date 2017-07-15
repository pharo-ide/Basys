signalling
signalAs: anError
	self new 
		nativeError: anError;
		signal: anError messageText