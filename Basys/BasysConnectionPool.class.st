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

{ #category : #accessing }
BasysConnectionPool >> remotePeer [
	^ remotePeer
]

{ #category : #accessing }
BasysConnectionPool >> remotePeer: anObject [
	remotePeer := anObject
]
