private
assignId: peerId receivedFrom: aBasysConnection

	| registeredPeer |
	self isIdentified ifTrue: [ 
		id = peerId ifFalse: [BasysIdentificationFailed signal].
		^self 
	].

	registeredPeer := network remotePeerWithId: peerId ifAbsent: [^id := peerId ]. 

	registeredPeer addNewConnection: aBasysConnection.
	registeredPeer becomeActiveToReplaceSamePeer: self.
	"it will replace all my references by registeredPeer. And it change registeredPeer class to be active"