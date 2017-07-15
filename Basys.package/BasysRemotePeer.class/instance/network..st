accessing
network: aBasysNetwork
	super network: aBasysNetwork.
	connectionPool maxWaitForBorrow: (network connectionTimeout * 2) asMilliSeconds.