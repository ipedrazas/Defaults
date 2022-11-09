name: string @tag(name)

#Compose:{
	services: {
		ga: {
			image: "\(name):aa3845e"
			ports: [
				"8080:8080",
			]
			environment: [
				"GITHUB_TOKEN=$GITHUB_TOKEN",
				"REDIS_HOST=redis:6379",
				"REDIS_PASSWORD",
			]
			volumes: [
				"./ghapi.yaml:/ghapi.yaml",
			]
			depends_on: [
				"redis",
			]
		}
		redis: {
			image: "redis"
			ports: ["6379:6379"]
		}
	}
}

