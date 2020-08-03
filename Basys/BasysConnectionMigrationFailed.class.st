"
I am an error about bad migration of given connection pool into another connection pool.
A pool restricts conditions where it can be merged with another pool. 
For example it is forbidden for the pool with busy connections (which is already being used).
"
Class {
	#name : #BasysConnectionMigrationFailed,
	#superclass : #Error,
	#category : #Basys
}
