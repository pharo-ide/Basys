I represent wrong protocol failure inside Basys network.
Concrete implementors of Basys network can use me to signal that data exchange with remote peer use incorrect protocol. I will be catched by BasysConnection to stop communication with "alien" peer. 

I can be signalled by :

	BasysWrongProtocolError signalAs: originalErrorInstance.
	 
    Instance Variables
	nativeError:		<Exception>