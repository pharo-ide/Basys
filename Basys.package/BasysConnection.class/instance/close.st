controlling
close
	"repeated process termination signals ProcessAlreadyTerminating exception which could stop image quit process with emergency screen. So we check here explicitly that process is not yet terminating"
	incomingDataProcess isTerminating ifFalse: [ incomingDataProcess terminate].
	self closeSocketSafely 