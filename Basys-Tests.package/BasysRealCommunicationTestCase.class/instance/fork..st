helpers
fork: aBlock

	| process |
	process := aBlock newProcess.
	process name: 'forked from ',  testSelector.
	forkedProcesses add: process.
	process resume.
	^process