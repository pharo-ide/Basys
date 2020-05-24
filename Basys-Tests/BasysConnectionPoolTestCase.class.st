Class {
	#name : #BasysConnectionPoolTestCase,
	#superclass : #TestCase,
	#instVars : [
		'connectionPool',
		'remotePeer'
	],
	#category : #'Basys-Tests'
}

{ #category : #testing }
BasysConnectionPoolTestCase class >> isAbstract [ 	
	^self = BasysConnectionPoolTestCase 
]

{ #category : #running }
BasysConnectionPoolTestCase >> createConnectionPool [
	self subclassResponsibility 
]

{ #category : #running }
BasysConnectionPoolTestCase >> setUp [
	super setUp.
	
	remotePeer := Mock new.
	remotePeer stub maxConnectionsCount willReturn: 100.
	Mock stub isValid willReturn: true. "To simulate valid connections by default"
		
	connectionPool := self createConnectionPool
]

{ #category : #tests }
BasysConnectionPoolTestCase >> testConvertingToActivePool [

	connectionPool beActive.
	
	connectionPool should beInstanceOf: BasysActiveConnectionPool
]

{ #category : #tests }
BasysConnectionPoolTestCase >> testConvertingToPassivePool [

	connectionPool bePassive.
	
	connectionPool should beInstanceOf: BasysPassiveConnectionPool
]
