
// #Target: {
name: string @tag(name)
platform: [...string] | *["linux/amd64"]
docker_build: bool | *false
compose: "\(name)-compose.yaml"
dns: string @tag(dns)
actions?: [...string]
