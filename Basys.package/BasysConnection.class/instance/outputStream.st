controlling
outputStream
	^outputStream ifNil: [ outputStream := network transferOutputStreamOn: socket]