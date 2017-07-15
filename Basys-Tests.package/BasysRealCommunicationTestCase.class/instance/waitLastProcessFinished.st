helpers
waitLastProcessFinished
	| lastProcess |
	lastProcess := forkedProcesses last.
	Processor yield.
	[
		[ lastProcess isTerminated | lastProcess isSuspended] whileFalse: [5 milliSeconds wait ]
	] valueWithin: 2 seconds onTimeout: [ self fail: 'Last process not terminated within ', 5 seconds printString ].

	lastProcess isTerminated ifFalse: [ self fail: 'Last process was suspended and not terminated' ]