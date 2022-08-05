
workspaceDir: string @tag(wkrspc)
targetName:   string @tag(target)
dataDir:      *"" | string @tag(data)
compName:   string @tag(name)
configDir: string @tag(config)

#Compose: {
	version: "3.9"
	services: {
		createChart: {
			image: "ipedrazas/k8s:v0.1.1"
			volumes: [
				"\(workspaceDir):/workspace",
				"\(configDir)/defaults/k8s/helm/starters:/root/.local/share/helm/starters",
			]
			// workspace
			working_dir: "\(workspaceDir)"
			command: ["sh", "-c", "helm create \(appName) --starter common-starter"]
		}

		populateValues: {
			image: "harbor.alacasa.uk/library/hvgen:v0.1.9.3"
			volumes: [
				"\(workspaceDir)/gp/targets/\(targetName)/target.yaml:/targets/target.yaml",
				"\(configDir)/config.yaml:/gp/config.yaml",
				if dataDir != "" {
					"\(dataDir):/data",
				},
				"\(workspaceDir):/workspace",
			]
		}
	}
}

// cue export helm-compose.cue  -t config="/Users/ivan/.config/gp" -t name=dapi -t target=helm -t data=/data -t wkrspc="/Users/ivan/workspace/dapi" -e "#Compose" --out yaml
// cue export helm-tags.cue helm-compose.cue --out yaml -e "#Compose"