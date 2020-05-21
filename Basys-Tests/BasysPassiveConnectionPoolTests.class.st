Class {
	#name : #BasysPassiveConnectionPoolTests,
	#superclass : #BasysConnectionPoolTestCase,
	#category : #'Basys-Tests'
}

{ #category : #running }
BasysPassiveConnectionPoolTests >> createConnectionPool [
	^BasysPassiveConnectionPool of: remotePeer
]
