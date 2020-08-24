"
I implement a thread safe pool of BasysConnection's for given BasysRemotePeer instance. 
Users should allocate connection, do the job and release it back: 

	connection := pool allocateConnection.
	pool releaseConnection: connection 

There is a suitable method to ensure that release is performed at the end:

	pool allocateConnectionFor: [ :connection |  ]

Users add new connections using: 

	pool addConnection: aConnection 
	
Remote peer restricts a number of connections which pool is allowed to have:

	remotePeer maxConnections 
	
I raise a BasysTooManyConnections error when user adds too many connections. Method #allowNewConnection performs required checks.

When all connections in the pool are busy the allocation operation will wait next free connection.

Both #addConnection: and #allocateConnection operations clean invalid connections detected in the pool:
	
	pool cleanInvalidConnections
	
It can be connections closed from remote side or broken by any other reason (from debugger for example).
In addition the allocation logic is built with a loop to periodically check the connectivity to avoid the corner case when all busy connections silently become invalid while allocation was in a waiting state (see #connectivityPollingRate).

My subclases add specific features depending on connectivity status of remote peer (which they belong to): 

- active pool is able to establish new connections by demand when no free connection is available.
When all connections are busy the active pool opens a new one (until it is allowed)

- passive pool fails allocation immediately when no connections exist in the pool.
It's unable to open connection by itself and therefore there is no reason to wait anything. It raises BasysConnectionDoesNotExist error.

There are several methods to test a type of pool:

- isActive
- isPassive
- isClosed

I implement converting methods to change the type of live pool instance:

- bePassive 
- beActive  

They use a change class primitive as very simple approach which does not require to create a new instance of new class.

Another method #close converts the pool to the BasysClosedConnectionPool class. It was introduced as hardcore approach to block any communication with remote side forever. Closed pool simply fails any operation with BasysRemotePeerClosed error. 
At first step the #close cleans the pool (using #clean method). It closes all connection (#close) and removes them from the pool. At the end pool becomes empty.

Methods to check the pool size:

- #isEmpty 
- #size  
- #busySize 
- #freeSize 
- #openSize 

To create pool instances use following example: 

	BasysActiveConnectionPool of: aRemotePeer 

Pools are created internaly by remote peer and it is not supposed to be used outside of it.

Internal Representation and Key Implementation Points.

    Instance Variables
	remotePeer:		<BasysRemotePeer>
	accessGuard:		<Mutex>
	connections:		<OrderedCollection<BasysConnection>>
	connectivityPollingRate:		<Duration>
	stateChangeSemaphore:		<Semaphore>
	remotePeer:		<BasysRemotePeer>
"
Class {
	#name : #BasysConnectionPool,
	#superclass : #Object,
	#instVars : [
		'remotePeer',
		'connections',
		'accessGuard',
		'connectivityPollingRate',
		'stateChangeSemaphore'
	],
	#category : #Basys
}

{ #category : #testing }
BasysConnectionPool class >> isAbstract [ 	
	^self = BasysConnectionPool 
]

{ #category : #'instance creation' }
BasysConnectionPool class >> of: aBasysRemotePeer [
	^self new 
		remotePeer: aBasysRemotePeer
]

{ #category : #controlling }
BasysConnectionPool >> addConnection: aBasysConnection [
	
	self changeStateBy: [ 
		self allowNewConnection.
		aBasysConnection remotePeer: remotePeer.	
		connections add: aBasysConnection.
	]
]

{ #category : #private }
BasysConnectionPool >> addNewConnection [
	| newConnection |
	newConnection := remotePeer newConnection.
	self addConnection: newConnection.
	^newConnection
]

{ #category : #controlling }
BasysConnectionPool >> allocateConnection [	

	[
		self guardAccessDuring: [
			self checkConnectivity.
			self nextFreeConnectionOrNil ifNotNil: [:freeConnection | 
				^freeConnection beBusy; yourself ]
		].
		"The timeout here is to handle a special case 	when all busy connections become invalid
		but the user processes did not release them yet. 
		This logic is to protect the pool from such cases to be more responsive"
		stateChangeSemaphore wait: connectivityPollingRate
	] repeat
]

{ #category : #controlling }
BasysConnectionPool >> allocateConnectionFor: communicationBlock [

	| connection communicationFailed |
	communicationFailed := false.
	[connection := self allocateConnection.
	
	[communicationBlock value: connection] on: Error do: [:err |
		communicationFailed := true.
		self releaseConnection: connection.
		err pass ]
	
	] ensure: [ 
		(communicationFailed not and: [connection notNil]) ifTrue: [ 
			self releaseConnection: connection ]]
]

{ #category : #private }
BasysConnectionPool >> allowNewConnection [
	self cleanInvalidConnections.
		
	self size >= remotePeer maxConnections ifTrue: [ ^ BasysTooManyConnections signal ]
]

{ #category : #controlling }
BasysConnectionPool >> beActive [ 
	MirrorPrimitives setClass: BasysActiveConnectionPool to: self
]

{ #category : #controlling }
BasysConnectionPool >> bePassive [ 
	MirrorPrimitives setClass: BasysPassiveConnectionPool to: self
]

{ #category : #accessing }
BasysConnectionPool >> busySize [

	^connections count: [ :each | each isBusy ]
]

{ #category : #private }
BasysConnectionPool >> changeStateBy: aBlock [

	self guardAccessDuring: aBlock.

	stateChangeSemaphore signal
]

{ #category : #private }
BasysConnectionPool >> checkConnectivity [
	self cleanInvalidConnections
]

{ #category : #private }
BasysConnectionPool >> cleanInvalidConnections [
	| invalidConnections |
	
	invalidConnections := connections reject: [ :each | each isValid ].
	invalidConnections do: [ :each | each close ] "close will remove conneciton from the pool"
]

{ #category : #controlling }
BasysConnectionPool >> clear [
	"Every #close operation here will remove closed connection from the pool
	(through #removeCloseConnection: method).
	Therefore #copy is required for safe enumeration"
	| currentConnections |
	currentConnections := connections copy.
	currentConnections do: [ :each | each close ]
]

{ #category : #controlling }
BasysConnectionPool >> close [
	MirrorPrimitives setClass: BasysClosedConnectionPool to: self.
	self clear
]

{ #category : #accessing }
BasysConnectionPool >> connectivityPollingRate [
	^ connectivityPollingRate
]

{ #category : #accessing }
BasysConnectionPool >> connectivityPollingRate: anObject [
	connectivityPollingRate := anObject
]

{ #category : #accessing }
BasysConnectionPool >> freeSize [

	^connections count: [ :each | each isBusy not ]
]

{ #category : #private }
BasysConnectionPool >> guardAccessDuring: aBlock [
	"Guard access should ensure that any error during given block will not leave the lock active.
	It allows to safely open debugger and continue usage of the pool.
	Otherwise any access to the pool would lock the process during debugging"
	| error result |
	result := accessGuard critical: [
		[aBlock value] on: Error do: [ :err | error := err ]  
	].
	"The initial error stack will be lost here 
	but it should not be an issue for senders of this method.
	More clever approach would be to support such behavior in mutex directly with special method:
		accessGuard criticalWithUnlockIfError: aBlock"
	error ifNotNil: [ ^error signal ]. 
	^result
]

{ #category : #testing }
BasysConnectionPool >> includesConnection: aConnection [ 

	^connections includes: aConnection
]

{ #category : #initialization }
BasysConnectionPool >> initialize [ 
	super initialize.
	connections := OrderedCollection new.
	accessGuard := Mutex new.
	stateChangeSemaphore := Semaphore new.
	connectivityPollingRate := 100 milliSeconds
]

{ #category : #testing }
BasysConnectionPool >> isActive [ 
	self subclassResponsibility 
]

{ #category : #testing }
BasysConnectionPool >> isClosed [
	^false
]

{ #category : #testing }
BasysConnectionPool >> isEmpty [ 
	^self size = 0
]

{ #category : #testing }
BasysConnectionPool >> isPassive [ 
	^self isActive not
]

{ #category : #controlling }
BasysConnectionPool >> migrateConnectionsInto: anotherConnectionPool [

	self changeStateBy: [ 
		connections reverseDo: [ :each | "reversed is used for safe removal of enumerated items"
			anotherConnectionPool addConnection: each.
			connections remove: each ]
	]
]

{ #category : #private }
BasysConnectionPool >> nextFreeConnectionOrNil [
	^connections detect: [ :each | each isBusy not ] ifNone: [ nil ]
]

{ #category : #accessing }
BasysConnectionPool >> openSize [

	^connections count: [ :each | each isOpened ]
]

{ #category : #controlling }
BasysConnectionPool >> releaseConnection: aBasysConnection [
		
	self changeStateBy: [ aBasysConnection beFree ]
]

{ #category : #accessing }
BasysConnectionPool >> remotePeer [
	^ remotePeer
]

{ #category : #accessing }
BasysConnectionPool >> remotePeer: anObject [
	remotePeer := anObject
]

{ #category : #controlling }
BasysConnectionPool >> removeClosedConnection: aConnection [

	self changeStateBy: [ connections remove: aConnection ifAbsent: []]
]

{ #category : #accessing }
BasysConnectionPool >> size [

	^connections size
]

{ #category : #controlling }
BasysConnectionPool >> waitOpenedConnection [	

	[
		self allocateConnectionFor: [:connection | 
			[ connection beOpened ] on: ConnectionTimedOut do: [:err | err retry ]. 
			^self ]
	] on: BasysConnectionDoesNotExist do: [ :err | 		
		stateChangeSemaphore wait.
		err retry
	]
]
