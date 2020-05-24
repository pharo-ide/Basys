Class {
	#name : #BasysConnectionPool,
	#superclass : #OPPool,
	#instVars : [
		'remotePeer'
	],
	#category : #Basys
}

{ #category : #'instance creation' }
BasysConnectionPool class >> of: aBasysRemotePeer [
	^self new 
		remotePeer: aBasysRemotePeer
]

{ #category : #private }
BasysConnectionPool >> destroyObject: aConnection [
	aConnection close
]

{ #category : #private }
BasysConnectionPool >> objectGoingToBeBorrowed: aConnection [
	aConnection isValid ifFalse: [OPAbortOperation signal]
]

{ #category : #accessing }
BasysConnectionPool >> remotePeer [
	^ remotePeer
]

{ #category : #accessing }
BasysConnectionPool >> remotePeer: anObject [
	remotePeer := anObject
]
