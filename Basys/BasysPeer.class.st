"
My subclasses represent logical peers inside a BasysNetwork. 
 
Internal Representation and Key Implementation Points.

    Instance Variables
	id:		<Object>
	network:		<BasysNetwork>
"
Class {
	#name : #BasysPeer,
	#superclass : #Object,
	#instVars : [
		'network',
		'id'
	],
	#category : #Basys
}

{ #category : #'instance variables' }
BasysPeer class >> inside: aNetwork [

	^self new 
		network: aNetwork
]

{ #category : #accessing }
BasysPeer >> id [
	^ id
]

{ #category : #accessing }
BasysPeer >> id: anObject [
	id := anObject
]

{ #category : #testing }
BasysPeer >> isConnected [ 
	self subclassResponsibility 
]

{ #category : #accessing }
BasysPeer >> network [
	^ network
]

{ #category : #accessing }
BasysPeer >> network: anObject [
	network := anObject
]

{ #category : #printing }
BasysPeer >> printOn: aStream [

	super printOn: aStream.
	aStream nextPut: $(; print: id; nextPut: $)
]
