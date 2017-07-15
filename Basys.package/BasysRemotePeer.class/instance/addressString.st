printing
addressString

	address ifNil: [ ^'Unknown address' ].
	
	^String streamContents: [ :s | address printSimpleStringOn: s ]