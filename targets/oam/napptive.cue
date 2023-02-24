OAM: {
	apiVersion: "core.oam.dev/v1beta1"
	kind:       "Application"
	metadata: {
		name: d2.name
		annotations: {
			version: d2.version
		}
	}
	spec: components: [{
		name: d2.name
		type: "webservice"
		properties: {
			image: "\(target.registry)/\(target.registry_user)/\(d2.name):\(d2.version)"
			ports: [{
				port: d2.port
				expose: true
			}]
		}
		traits: [{
			type: "napptive-ingress" 
			properties: {
				name: d2.name
				port: d2.port
				path: "/"
			}
		}]
	}]
}

