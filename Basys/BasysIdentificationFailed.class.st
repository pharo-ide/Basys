"
I represent failure when new connection was not able to identify remote peer with existing id:
Peer should not change id when it was already identified
"
Class {
	#name : #BasysIdentificationFailed,
	#superclass : #Error,
	#category : 'Basys'
}

{ #category : #initialization }
BasysIdentificationFailed >> initialize [
	super initialize.
	
	messageText := 'Peer should not change id when it was already identified'
]
