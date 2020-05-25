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

{ #category : #controlling }
BasysConnectionPool >> beActive [ 
	MirrorPrimitives setClass: BasysActiveConnectionPool to: self
]

{ #category : #controlling }
BasysConnectionPool >> bePassive [ 
	MirrorPrimitives setClass: BasysPassiveConnectionPool to: self
]

{ #category : #private }
BasysConnectionPool >> destroyObject: aConnection [
	aConnection close
]

{ #category : #testing }
BasysConnectionPool >> isActive [ 
	self subclassResponsibility 
]

{ #category : #testing }
BasysConnectionPool >> isPassive [ 
	^self isActive not
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
