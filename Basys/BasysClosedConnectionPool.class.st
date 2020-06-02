Class {
	#name : #BasysClosedConnectionPool,
	#superclass : #BasysConnectionPool,
	#category : #Basys
}

{ #category : #'object-lifecycle' }
BasysClosedConnectionPool >> beActive [

	BasysRemotePeerClosed signal
]

{ #category : #'object-lifecycle' }
BasysClosedConnectionPool >> bePassive [

	BasysRemotePeerClosed signal
]

{ #category : #testing }
BasysClosedConnectionPool >> isActive [ 
	^false
]

{ #category : #testing }
BasysClosedConnectionPool >> isClosed [
	^true
]

{ #category : #testing }
BasysClosedConnectionPool >> isPassive [ 
	^false
]

{ #category : #'object-lifecycle' }
BasysClosedConnectionPool >> makeObject [

	^BasysRemotePeerClosed signal
]

{ #category : #'object-lifecycle' }
BasysClosedConnectionPool >> objectToPool: aBasysConnection [
	
	BasysRemotePeerClosed signal
]

{ #category : #'object-lifecycle' }
BasysClosedConnectionPool >> unsafeBorrow [ 
	
	^BasysRemotePeerClosed signal
]
