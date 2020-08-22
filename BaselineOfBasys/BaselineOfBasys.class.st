Class {
	#name : #BaselineOfBasys,
	#superclass : #BaselineOf,
	#category : #BaselineOfBasys
}

{ #category : #baselines }
BaselineOfBasys >> baseline: spec [
	<baseline>
	spec for: #'common' do: [
		spec 
			baseline: 'TCPServer' with: [ 
				spec repository: 'github://pharo-ide/TCPServer:v1.0.1' ];
			project: 'TCPServerCore' copyFrom: 'TCPServer' with: [
				spec loads: 'Core'];
			project: 'TCPServerTests' copyFrom: 'TCPServer' with: [
				spec loads: 'Tests'];
			baseline: 'Mocketry' with: [
				spec repository: 'github://dionisiydk/Mocketry:v6.0.2' ].
		spec 
			package: 'Basys' with: [ spec requires: #('TCPServerCore')];
			package: 'Basys-Tests' with: [ spec requires: #('Basys' 'TCPServerTests' 'Mocketry')].
		spec 
			group: 'Core' with: #('Basys');
			group: 'Tests' with: #('Basys-Tests'). ].

]

{ #category : #accessing }
BaselineOfBasys >> projectClass [
	^ [ self class environment at: #MetacelloCypressBaselineProject ]
		on: NotFound
		do: [ super projectClass ]
]
