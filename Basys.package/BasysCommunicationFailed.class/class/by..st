instance creation
by: anError
	anError class == self ifTrue: [ anError pass ].
	
	^self new 
		reason: anError;
		signal