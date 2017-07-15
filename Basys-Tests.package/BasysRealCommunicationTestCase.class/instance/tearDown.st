running
tearDown

	forkedProcesses do: #terminate.
	clientSideNetwork close.

	super tearDown.