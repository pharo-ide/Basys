Class {
	#name : #BasysOpenedConnectionPoolTestCase,
	#superclass : #BasysConnectionPoolTestCase,
	#category : #'Basys-Tests'
}

{ #category : #testing }
BasysOpenedConnectionPoolTestCase class >> isAbstract [ 	
	^self = BasysOpenedConnectionPoolTestCase 
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testAssignsPeerForAddedConnections [

	| connection |
	connection := BasysConnection new.
	
	connectionPool addConnection: connection.
	
	connection remotePeer should be: remotePeer
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testChoosesFreeConnectionForAllocation [

	| reusedConnection freeConnection busyConnection |
	freeConnection := Mock new.
	busyConnection := Mock new.
	busyConnection stub isBusy willReturn: true.
	connectionPool addConnection: busyConnection; addConnection: freeConnection.
	
	reusedConnection := connectionPool allocateConnection.
	reusedConnection should be: freeConnection
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testChoosesValidConnectionsForAllocation [

	| invalidConnection validConnection allocatedConnection |
	validConnection := Mock new.
	invalidConnection := Mock new.
	connectionPool addConnection: validConnection; addConnection: invalidConnection.
	invalidConnection stub isValid willReturn: false.

	allocatedConnection := connectionPool allocateConnection.
	
	allocatedConnection should be: validConnection
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testClosesAllConnectionsDuringClear [

	| connection1 connection2 |
	connection1 := Mock new.	
	connection2 := Mock new.
	
	connectionPool addConnection: connection1; addConnection: connection2.
	
	connectionPool clear.
	
	connection1 should receive close.
	connection2 should receive close
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testClosesAllConnectionsDuringClose [

	| connection1 connection2 |
	connection1 := Mock new.	
	connection2 := Mock new.
	connectionPool addConnection: connection1; addConnection: connection2.
	
	connectionPool close.
	
	connection1 should receive close.
	connection2 should receive close
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testClosesAndRemovesInvalidConnectionsDuringAdditionOfNewOne [

	| invalidConnection validConnection newConnection |
	validConnection := Mock new.
	invalidConnection := Mock new.
	connectionPool addConnection: validConnection; addConnection: invalidConnection.
	invalidConnection stub isValid willReturn: false.

	newConnection := Mock new.
	connectionPool addConnection: newConnection	.
	
	invalidConnection should receive close.
	connectionPool should not be includesConnection: invalidConnection.
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testClosesAndRemovesInvalidConnectionsDuringAllocation [

	| invalidConnection validConnection |
	validConnection := Mock new.
	invalidConnection := Mock new.
	connectionPool addConnection: validConnection; addConnection: invalidConnection.
	invalidConnection stub isValid willReturn: false.

	connectionPool allocateConnection.
	
	invalidConnection should receive close.
	connectionPool should not be includesConnection: invalidConnection
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testConvertsItselfToClosedPoolDuringClose [

	connectionPool close.
	
	connectionPool should beInstanceOf: BasysClosedConnectionPool 
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testConvertsToActivePool [

	connectionPool beActive.
	
	connectionPool should beInstanceOf: BasysActiveConnectionPool
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testConvertsToPassivePool [

	connectionPool bePassive.
	
	connectionPool should beInstanceOf: BasysPassiveConnectionPool
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testDetectsFreeConnectionWithoutReleaseSignal [
	| busyConnection retrievedConnection |
	remotePeer stub maxConnections willReturn: 1.
	busyConnection := Mock new.
	connectionPool addConnection: busyConnection.
	busyConnection stub isBusy willReturn: true.
	connectionPool connectivityPollingRate: 20 milliSeconds.
	
	[retrievedConnection := connectionPool allocateConnection] forkAt: Processor activePriority + 1.
	retrievedConnection should be: nil.
	
	busyConnection stub isBusy willReturn: false.
	50 milliSecond wait.
	retrievedConnection should be: busyConnection
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testDoesNotLockWhenFailsToAddTooManyConnections [
	| connection connection2 connection3 process |
	connection := Mock new.
	connection2 := Mock new.
	connection3 := Mock new.
	remotePeer stub maxConnections willReturn: 1.
	connectionPool addConnection: connection.

	process := [ [connectionPool addConnection: connection2] on: BasysTooManyConnections do: [ :err | 
						Processor activeProcess suspend ] ] forkAt: Processor activePriority + 1.
	process should be isSuspended.
	
	[connectionPool addConnection: connection3] should raise: BasysTooManyConnections
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testFailsAllocationWhenCloseHappensDuringWait [
	| busyConnection  error process |
	remotePeer stub maxConnections willReturn: 1.
	busyConnection := Mock new.
	connectionPool addConnection: busyConnection.
	busyConnection stub isBusy willReturn: true.
		
	process := [ error := [connectionPool allocateConnection] should fail ] 
		forkAt: Processor activePriority + 1.
	process should not be isTerminated.
	
	connectionPool close.
	"In real scenario following call would be triggered from connection close"
	connectionPool removeClosedConnection: busyConnection.
	process should be isTerminated.
	error should beInstanceOf: BasysRemotePeerClosed 
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testFailsToAddTooManyConnections [

	| connection connection2 err |
	connection := Mock new.
	connection2 := Mock new.
	remotePeer stub maxConnections willReturn: 1.
	
	connectionPool addConnection: connection.
	[connectionPool addConnection: connection2] should raise: BasysTooManyConnections
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testIsNotClosed [

	connectionPool should not be isClosed
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testKnowsBusyConnectionsCount [

	| busyConnection |
	connectionPool addConnection: Mock new.
	connectionPool addConnection: Mock new.
	busyConnection := Mock new.
	connectionPool addConnection: busyConnection.
	busyConnection stub isBusy willReturn: true.
	
	connectionPool busySize should equal: 1
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testKnowsConnectionsCount [

	connectionPool addConnection: Mock new.
	connectionPool addConnection: Mock new.
	
	connectionPool size should equal: 2
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testKnowsFreeConnectionsCount [

	| busyConnection |
	connectionPool addConnection: Mock new.
	connectionPool addConnection: Mock new.
	busyConnection := Mock new.
	connectionPool addConnection: busyConnection.
	busyConnection stub isBusy willReturn: true.
	
	connectionPool freeSize should equal: 2
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testKnowsOpenedConnectionsCount [

	| openedConnection |
	connectionPool addConnection: Mock new.
	connectionPool addConnection: Mock new.
	openedConnection := Mock new.
	connectionPool addConnection: openedConnection.
	openedConnection stub isOpened willReturn: true.
	
	connectionPool openSize should equal: 1
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testMarksAllocatedConnectionsAsBusy [

	| allocatedConnection freeConnection |
	freeConnection := Mock new.
	connectionPool addConnection: freeConnection.
	
	allocatedConnection := connectionPool allocateConnection.
	allocatedConnection should receive beBusy
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testMarksReleasedConnectionsAsFree [

	| connection |
	connection := Mock new.

	connectionPool releaseConnection: connection.
	
	connection should receive beFree
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testMigratesConnectionsIntoAnotherPool [

	| anotherPool connection |
	connection := Mock new.
	anotherPool := Mock new.
	connectionPool addConnection: connection.
	
	connectionPool migrateConnectionsInto: anotherPool.
	
	anotherPool should receive addConnection: connection.
	connectionPool should be isEmpty
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testPassesCommunicationFailureToSender [
	| freeConnection error |
	freeConnection := Mock new.
	connectionPool addConnection: freeConnection.	
	error := Error new.
	[
		connectionPool allocateConnectionFor: [ :connection | error signal ] 
	] should raise: error
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testReleasesConnectionWhenCommunicationCompletes [
	| freeConnection |
	freeConnection := Mock new.
	connectionPool addConnection: freeConnection.	
		
	connectionPool allocateConnectionFor: [ :connection | 
		connection should be: freeConnection.
		freeConnection should receive beBusy.
		freeConnection should not receive beFree ].
	
	freeConnection should receive beFree.
	
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testReleasesConnectionWhenCommunicationFailed [
	| freeConnection |
	freeConnection := Mock new.
	connectionPool addConnection: freeConnection.	
		
	[connectionPool allocateConnectionFor: [ :connection | 
		connection should be: freeConnection.
		freeConnection should receive beBusy.
		freeConnection should not receive beFree.
		self error: 'test error']
	] on: Error do: [ :err | 
		freeConnection should receive beFree once].
	freeConnection should receive beFree once
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testRemovesClosedConnection [

	| connection |
	connection := Mock new.
	connectionPool addConnection: connection.
	
	connectionPool removeClosedConnection: connection.
	
	connectionPool should be isEmpty
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testWaitsAnyNewConnectionWhenAllAreBusy [
	| retrievedConnection  newConnection busyConnection |
	remotePeer stub maxConnections willReturn: 1.
	busyConnection := Mock new.
	busyConnection stub isBusy willReturn: true.
	connectionPool addConnection: busyConnection.	
		
	[retrievedConnection := connectionPool allocateConnection] forkAt: Processor activePriority + 1.
	retrievedConnection should be: nil.
	
	newConnection := Mock new.
	remotePeer stub maxConnections willReturn: 2.
	connectionPool addConnection: newConnection.
	retrievedConnection should be: newConnection
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testWaitsBusyConnectionsToBeFreeWhenAllAreBusy [
	| busyConnection retrievedConnection  |
	remotePeer stub maxConnections willReturn: 1.
	busyConnection := Mock new.
	connectionPool addConnection: busyConnection.
	busyConnection stub isBusy willReturn: true.
		
	[retrievedConnection := connectionPool allocateConnection] forkAt: Processor activePriority + 1.
	retrievedConnection should be: nil.
	busyConnection stub isBusy willReturn: false.
	connectionPool releaseConnection: busyConnection.
	retrievedConnection should be: busyConnection
]

{ #category : #tests }
BasysOpenedConnectionPoolTestCase >> testWaitsValidConnectionWhenFreeWasInvalid [
	| busyConnection retrievedConnection  invalidConnection |
	remotePeer stub maxConnections willReturn: 2.
	invalidConnection := Mock new.
	invalidConnection stub isBusy willReturn: true.
	connectionPool addConnection: invalidConnection.
	busyConnection := Mock new.
	busyConnection stub isBusy willReturn: true.
	connectionPool addConnection: busyConnection.
	
	[retrievedConnection := connectionPool allocateConnection] forkAt: Processor activePriority + 1.
	retrievedConnection should be: nil.
	
	invalidConnection stub isBusy willReturn: false.
	invalidConnection stub isValid willReturn: false.
	busyConnection stub isBusy willReturn: false.
	connectionPool releaseConnection: invalidConnection.
	retrievedConnection should be: busyConnection
]
