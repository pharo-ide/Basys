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

{ #category : #tests }
BasysConnectionPoolTestCase >> testMigrationIntoAnotherPool [

	| anotherPool connection |
	connection := Mock new.
	anotherPool := Mock new.
	connectionPool objectToPool: connection.
	
	connectionPool migrateConnectionsInto: anotherPool.
	
	anotherPool should receive objectToPool: connection.
	connectionPool numberOfAvailableObjects should be: 0
]

{ #category : #tests }
BasysConnectionPoolTestCase >> testMigrationIntoAnotherPoolShouldBeForbiddenWhenThereIsBusyConnection [

	| connection |
	connection := Mock new.
	connectionPool objectToPool: connection.
	connectionPool borrow.
	
	[connectionPool migrateConnectionsInto: #anotherPool] should raise: BasysConnectionMigrationFailed.
	connectionPool numberOfAvailableObjects should be: 1
]

{ #category : #tests }
BasysConnectionPoolTestCase >> testPoolingConnetionShouldSetItsRemotePeer [

	| connection |
	connection := BasysConnection new.
	
	connectionPool objectToPool: connection.
	
	connection remotePeer should be: remotePeer
]
