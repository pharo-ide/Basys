controlling
inputStream
	^inputStream ifNil: [ inputStream := network transferInputStreamOn: socket]
