Class {
	#name : #BasysRemotePeerTestCase,
	#superclass : #BasysPeerTestCase,
	#instVars : [
		'peerAddress'
	],
	#category : 'Basys-Tests'
}

{ #category : #testing }
BasysRemotePeerTestCase class >> isAbstract [
	^self == BasysRemotePeerTestCase 
]

{ #category : #running }
BasysRemotePeerTestCase >> setUp [
	super setUp.
	
	peerAddress := #peerAddress.	
	
	peer address: peerAddress.
]

{ #category : #tests }
BasysRemotePeerTestCase >> testBelongsToOwnAddress [

	| actual |
	peer address: 'some address object' copy.
	
	actual := peer isBelongsTo: 'some address object' copy.
	
	actual should be: true
]

{ #category : #tests }
BasysRemotePeerTestCase >> testConnectionsCount [
	
	peer maxConnectionsCount: 10.
	peer connectionPool objectToPool: #connection1.
	peer connectionPool objectToPool: #connection2.	 
	
	peer connectionsCount should be: 2
]

{ #category : #tests }
BasysRemotePeerTestCase >> testConnectionsCountWhenNothingExists [

	peer connectionsCount should be: 0
]

{ #category : #tests }
BasysRemotePeerTestCase >> testCreatingNewConnection [

	| connection |
	connection := peer newConnection.
	
	connection should beInstanceOf: BasysConnection.
	connection network should be: network.
	connection remotePeer should be: peer
]

{ #category : #tests }
BasysRemotePeerTestCase >> testGettingLocalPeerId [

	network stub localPeerId willReturn: #localPeerId.
	
	peer localPeerId should be: #localPeerId
]

{ #category : #tests }
BasysRemotePeerTestCase >> testImportingConnectionsFromSomeConnectionPool [

	[:connectionPool :anotherConnectionPool :eachConnection |		
		peer connectionPool: connectionPool.
		[ peer importConnectionsFrom: anotherConnectionPool]
			should strictly satisfy: 
		[(anotherConnectionPool migrateObjectsInto: connectionPool andDo: Any) will: [ :arg1 :arg2 | arg2 value: eachConnection ].
		eachConnection remotePeer: peer ].

	] runWithMocks 
]

{ #category : #tests }
BasysRemotePeerTestCase >> testIsIdentified [
	
	peer id: nil.
	
	peer should not be isIdentified.
	
	peer id: #peerId.
	
	peer should be isIdentified.
]

{ #category : #tests }
BasysRemotePeerTestCase >> testNotBelongsToDifferentAddress [

	| actual |
	peer address: 'some address object'.
	
	actual := peer isBelongsTo: 'different address'.
	
	actual should be: false
]

{ #category : #tests }
BasysRemotePeerTestCase >> testReceivingIncomingDataPackets [

	[:transporter |		
		[ (peer receiveIncomingDataPacketBy: #socket) should be: #result]
			should strictly satisfy: 
		[(network receiveIncomingDataPacketFrom: peer by: #socket) willReturn: #result].

	] runWithMocks 
]
