Class {
	#name : #BasysPeerTestCase,
	#superclass : #TestCase,
	#instVars : [
		'peer',
		'network'
	],
	#category : 'Basys-Tests'
}

{ #category : #testing }
BasysPeerTestCase class >> isAbstract [
	^self == BasysPeerTestCase 
]

{ #category : #running }
BasysPeerTestCase >> peerClass [
	self subclassResponsibility 
]

{ #category : #running }
BasysPeerTestCase >> setUp [

	super setUp.
	
	network := Mock new.
	
	peer := self peerClass inside: network 
]
