Class {
	#name : #BasysLocalPeerTests,
	#superclass : #BasysPeerTestCase,
	#category : 'Basys-Tests'
}

{ #category : #running }
BasysLocalPeerTests >> peerClass [
	^BasysLocalPeer 
]

{ #category : #testing }
BasysLocalPeerTests >> testHasIdByDefault [

	peer id should not be: nil
]
