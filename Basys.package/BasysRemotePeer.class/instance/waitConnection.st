operations
waitConnection
	| done |
	done := false.
	[
		[
			[self execute: [ :connection | done := true ]] 
				valueWithin: 100 milliSeconds onTimeout: [  ]
		] on: ConnectionTimedOut, OPTimedOutError do: [ :err | ].
	] doWhileFalse: [done]