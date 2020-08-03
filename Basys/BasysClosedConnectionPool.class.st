"
I am a special kind of pool to emulate a closed state of remote peer.

I am introduced to block any communication with remote side. 
I simply fail all pool operations with BasysRemotePeerClosed error. 

My instances are normally created during remote peer #close operation where current pool instance is cleaned and closed:
	pool close
"
Class {
	#name : #BasysClosedConnectionPool,
	#superclass : #BasysConnectionPool,
	#category : #Basys
}

{ #category : #controlling }
BasysClosedConnectionPool >> allowNewConnection [ 
	BasysRemotePeerClosed signal 	
]

{ #category : #controlling }
BasysClosedConnectionPool >> beActive [

	BasysRemotePeerClosed signal
]

{ #category : #controlling }
BasysClosedConnectionPool >> bePassive [

	BasysRemotePeerClosed signal
]

{ #category : #controlling }
BasysClosedConnectionPool >> checkConnectivity [
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
