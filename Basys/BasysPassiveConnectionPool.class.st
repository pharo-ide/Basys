"
I am a special kind of pool which is unable to open new connection with remote peer.

I raise a BasysConnectionDoesNotExist error when user asks new connection and nothing exists
"
Class {
	#name : #BasysPassiveConnectionPool,
	#superclass : #BasysConnectionPool,
	#category : #Basys
}

{ #category : #private }
BasysPassiveConnectionPool >> checkConnectivity [
	super checkConnectivity.
	
	connections ifEmpty: [ BasysNoConnection signal ]
]

{ #category : #testing }
BasysPassiveConnectionPool >> isActive [
	^false
]
