Class {
	#name : #BasysPassiveConnectionPoolTests,
	#superclass : #BasysOpenedConnectionPoolTestCase,
	#category : #'Basys-Tests'
}

{ #category : #running }
BasysPassiveConnectionPoolTests >> createConnectionPool [
	^BasysPassiveConnectionPool of: remotePeer
]

{ #category : #tests }
BasysPassiveConnectionPoolTests >> testAllowsToWaitConnectionWhenNothingExists [
	| connection done |
	connection := Mock new.
	done := false.
	[connectionPool waitOpenedConnection. done := true] forkAt: Processor activePriority + 1.
	done should be: false.
	
	connectionPool addConnection: connection.
	done should be: true.
	connection should receive beOpened
]

{ #category : #tests }
BasysPassiveConnectionPoolTests >> testDoesNotLockWhenFailsToAllocateConnection [
	| process |

	process := [ [connectionPool allocateConnection] on: BasysConnectionDoesNotExist do: [ :err | 
						Processor activeProcess suspend ] ] forkAt: Processor activePriority + 1.
	process should be isSuspended.
	
	[connectionPool allocateConnection] should raise: BasysConnectionDoesNotExist 
]

{ #category : #tests }
BasysPassiveConnectionPoolTests >> testFailsAllocationWhenAllConnectionsAreInvalid [

	| invalidConnection |
	invalidConnection := Mock new.
	connectionPool addConnection: invalidConnection.
	invalidConnection stub isValid willReturn: false.
	
	[connectionPool allocateConnection] should raise: BasysConnectionDoesNotExist
]

{ #category : #tests }
BasysPassiveConnectionPoolTests >> testFailsAllocationWhenNoConnectionExists [

	[connectionPool allocateConnection] should raise: BasysConnectionDoesNotExist
]

{ #category : #tests }
BasysPassiveConnectionPoolTests >> testFailsAllocationWhenWaitingCompletesWithInvalidFreeConnection [
	| busyConnection  error process |
	remotePeer stub maxConnections willReturn: 1.
	busyConnection := Mock new.
	connectionPool addConnection: busyConnection.
	busyConnection stub isBusy willReturn: true.
		
	process := [ error := [connectionPool allocateConnection] should fail ] 
		forkAt: Processor activePriority + 1.
	process should not be isTerminated.
	
	busyConnection stub isValid willReturn: false.
	busyConnection stub isBusy willReturn: false.
	connectionPool releaseConnection: busyConnection.
	process should be isTerminated.
	error should beInstanceOf: BasysConnectionDoesNotExist 
]

{ #category : #tests }
BasysPassiveConnectionPoolTests >> testFailsWhenAllBusyConnectionsBecomeInvalidDuringAllocationWait [
	| busyConnection error process |
	remotePeer stub maxConnections willReturn: 1.
	busyConnection := Mock new.
	connectionPool addConnection: busyConnection.
	busyConnection stub isBusy willReturn: true.
	connectionPool connectivityPollingRate: 20 milliSeconds.
	
	process := [error := [connectionPool allocateConnection] should fail] forkAt: Processor activePriority + 1.
	process should not be isTerminated.
	
	busyConnection stub isValid willReturn: false.
	50 milliSecond wait.
	error should beInstanceOf: BasysConnectionDoesNotExist
]

{ #category : #tests }
BasysPassiveConnectionPoolTests >> testIsNotActive [ 

	connectionPool should not be isActive
]

{ #category : #tests }
BasysPassiveConnectionPoolTests >> testIsPassive [ 

	connectionPool should be isPassive
]
