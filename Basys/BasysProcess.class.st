"
I represent process which handle connection incoming data in background. 
I can be created by network:
	network prepareProcessingOf: dataObject receivedFrom: aBasysRemotePeer
	
Public API and Key Messages

- run
	starts process

Internal Representation and Key Implementation Points.

    Instance Variables
	data:		<Object>
	network:		<BasysNetwork>
	realProcess:		<Process>
	senderPeer:		<BasysRemotePeer>
"
Class {
	#name : #BasysProcess,
	#superclass : #Object,
	#instVars : [
		'network',
		'data',
		'senderPeer',
		'realProcess'
	],
	#category : 'Basys'
}

{ #category : #'instance creation' }
BasysProcess class >> for: aNetwork with: dataObject receivedFrom: aRemotePeer [
	^self new 
		network: aNetwork;
		data: dataObject;
		senderPeer: aRemotePeer 
]

{ #category : #private }
BasysProcess >> body [

	network process: data receivedFrom: senderPeer
]

{ #category : #accessing }
BasysProcess >> data [
	^ data
]

{ #category : #accessing }
BasysProcess >> data: anObject [
	data := anObject
]

{ #category : #accessing }
BasysProcess >> network [
	^ network
]

{ #category : #accessing }
BasysProcess >> network: anObject [
	network := anObject
]

{ #category : #accessing }
BasysProcess >> realProcess [
	^ realProcess
]

{ #category : #accessing }
BasysProcess >> realProcess: anObject [
	realProcess := anObject
]

{ #category : #controlling }
BasysProcess >> run [

	realProcess := [ self body ] 
		forkAt: network processingPriority named: network printString
]

{ #category : #accessing }
BasysProcess >> senderPeer [
	^ senderPeer
]

{ #category : #accessing }
BasysProcess >> senderPeer: anObject [
	senderPeer := anObject
]
