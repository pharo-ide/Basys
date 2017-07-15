operations
execute: aBlock

	| error |
	connectionPool withPooled: [:connection |
		[aBlock value: connection] on: Error do: [ :err |
			BasysCommunicationFailed by: err.
			error := err]].
	
	error ifNotNil: [ error signal ]