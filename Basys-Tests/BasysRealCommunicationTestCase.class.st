Class {
	#name : #BasysRealCommunicationTestCase,
	#superclass : #TCPServerTestCase,
	#instVars : [
		'forkedProcesses',
		'serverSideNetwork',
		'clientSideNetwork'
	],
	#category : 'Basys-Tests'
}

{ #category : #testing }
BasysRealCommunicationTestCase class >> isAbstract [
	^self == BasysRealCommunicationTestCase 
]

{ #category : #helpers }
BasysRealCommunicationTestCase >> connectToServerPeer [

	^clientSideNetwork remotePeerAt: self serverAddress. 
]

{ #category : #helpers }
BasysRealCommunicationTestCase >> fork: aBlock [

	| process |
	process := aBlock newProcess.
	process name: 'forked from ',  testSelector.
	forkedProcesses add: process.
	process resume.
	^process
]

{ #category : #helpers }
BasysRealCommunicationTestCase >> forkAndHalt: aBlock [

	self fork: aBlock.
	self halt.
]

{ #category : #helpers }
BasysRealCommunicationTestCase >> forkAndWait: aBlock [

	self fork: aBlock.
	self waitLastProcessFinished 
]

{ #category : #running }
BasysRealCommunicationTestCase >> networkClass [
	self subclassResponsibility 
]

{ #category : #running }
BasysRealCommunicationTestCase >> passForkedProcesses [
	"While this trick looks bad it is quite difficult to control processes which are forked by tested code.
	This yield loop works well in practice.
	It allow all forked processes proceed"
	10 timesRepeat: [Processor yield]
]

{ #category : #running }
BasysRealCommunicationTestCase >> serverClass [
	^BasysServer
]

{ #category : #running }
BasysRealCommunicationTestCase >> setUp [
	super setUp.
	
	forkedProcesses := OrderedCollection new.
	
	serverSideNetwork := self networkClass new. 	
	server network: serverSideNetwork .	
	server start	.
		
	clientSideNetwork := self networkClass new
]

{ #category : #running }
BasysRealCommunicationTestCase >> tearDown [

	forkedProcesses do: #terminate.
	clientSideNetwork close.

	super tearDown.
]

{ #category : #helpers }
BasysRealCommunicationTestCase >> waitLastProcessFinished [
	| lastProcess |
	lastProcess := forkedProcesses last.
	Processor yield.
	[
		[ lastProcess isTerminated | lastProcess isSuspended] whileFalse: [5 milliSeconds wait ]
	] valueWithin: 2 seconds onTimeout: [ self fail: 'Last process not terminated within ', 5 seconds printString ].

	lastProcess isTerminated ifFalse: [ self fail: 'Last process was suspended and not terminated' ]
]

{ #category : #running }
BasysRealCommunicationTestCase >> waitServerSidePeer [
	
	self waitUntil: [ serverSideNetwork remotePeers notEmpty ].
	^serverSideNetwork remotePeers anyOne
]

{ #category : #running }
BasysRealCommunicationTestCase >> waitUntil: conditionBlock [
	
	conditionBlock whileFalse: [Processor yield]
]
