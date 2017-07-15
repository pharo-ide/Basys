baselines
baseline: spec
	<baseline>
	spec for: #'common' do: [
		spec 
			baseline: 'TCPServer' with: [ 
				spec repository: 'github://dionisiydk/TCPServer:v0.1.x' ];
			project: 'TCPServerCore' copyFrom: 'TCPServer' with: [
				spec loads: 'Core'];
			project: 'TCPServerTests' copyFrom: 'TCPServer' with: [
				spec loads: 'Tests'];
			baseline: 'ObjectPool' with: [ 
				spec repository: 'github://dionisiydk/ObjectPool:v0.3.x' ];
			project: 'ObjectPoolCore' copyFrom: 'ObjectPool' with: [
				spec loads: 'Core'];
			project: 'ObjectPoolTests' copyFrom: 'ObjectPool' with: [
				spec loads: 'Tests'];
			baseline: 'Mocketry' with: [
				spec repository: 'github://dionisiydk/Mocketry:v4.0.x' ].
		spec 
			package: 'Basys' with: [ spec requires: #('TCPServerCore' 'ObjectPoolCore')];
			package: 'Basys-Tests' with: [ spec requires: #('TCPServerTests' 'Basys' 'ObjectPoolTests' 'Mocketry')].
		spec 
			group: 'Core' with: #('Basys');
			group: 'Tests' with: #('Basys-Tests'). ].
