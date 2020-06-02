Class {
	#name : #BasysConnectionPool,
	#superclass : #OPPool,
	#instVars : [
		'remotePeer'
	],
	#category : #Basys
}

{ #category : #testing }
BasysConnectionPool class >> isAbstract [ 	
	^self = BasysConnectionPool 
]

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

{ #category : #controlling }
BasysConnectionPool >> close [
	MirrorPrimitives setClass: BasysClosedConnectionPool to: self.
	self clear
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
BasysConnectionPool >> isClosed [
	^false
]

{ #category : #testing }
BasysConnectionPool >> isPassive [ 
	^self isActive not
]

{ #category : #controlling }
BasysConnectionPool >> migrateConnectionsInto: anotherConnectionPool [

	self critical: [ 
		borrowedObjects ifNotEmpty: [ 
			"Pool allows migration only when all objects are free"
			BasysConnectionMigrationFailed signal ].
		
		idleObjects do: [ :each | 
			anotherConnectionPool objectToPool: each].
		idleObjects removeAll]
]

{ #category : #private }
BasysConnectionPool >> objectGoingToBeBorrowed: aConnection [
	aConnection isValid ifFalse: [OPAbortOperation signal]
]

{ #category : #private }
BasysConnectionPool >> objectToPool: aBasysConnection [
	aBasysConnection remotePeer: remotePeer.
	
	super objectToPool: aBasysConnection
]

{ #category : #accessing }
BasysConnectionPool >> remotePeer [
	^ remotePeer
]

{ #category : #accessing }
BasysConnectionPool >> remotePeer: anObject [
	remotePeer := anObject
]
