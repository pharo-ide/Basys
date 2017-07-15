controlling
incomingDataLoop

	[
		[
			[
				[self processIncomingDataPacket] on: ConnectionTimedOut, PrimitiveFailed do: [ :err | ]
		 	] repeat
		] on: BasysWrongProtocolError do: [ :err | self closeSocketSafely ]
	] on: ConnectionClosed do: [ :err |  ]