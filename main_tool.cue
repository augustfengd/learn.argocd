package main

import (
	"encoding/yaml"
	"encoding/json"
	"encoding/base64"
	"tool/exec"
	"tool/cli"
)

#cluster: {
	name: "learn"
	kubectl: ["kubectl", "--context", "k3d-" + (name)]
}

#repositorySecret: {
	apiVersion: "v1"
	kind:       "Secret"
	metadata: {
		name:      string
		namespace: "argocd"
		labels: {
			"argocd.argoproj.io/secret-type": "repository"
		}
	}
	stringData: {
		username: "augustfengd"
		password: string
		url:      "https://github.com/augustfengd/learn-argocd"
	}
	type: "Opaque"
}

command: setup: {
	github: exec.Run & {
		cmd: ["sops", "-d", "secrets/github.enc.json"]
		stdout: string
	}

	cluster: exec.Run & {
		cmd: ["k3d", "cluster", "create", #cluster.name]
	}

	argocd: {
		namespace: exec.Run & {
			$dep: command.setup["cluster"].$done
			cmd:  #cluster.kubectl + ["create", "namespace", "argocd"]
		}
		manifests: exec.Run & {
			$dep: command.setup["argocd"]["namespace"].$done
			cmd:  #cluster.kubectl + ["apply", "-n", "argocd", "-f", "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"]
		}
	}

	applications: {
		repo: exec.Run & {
			$dep:  command.setup["argocd"]["namespace"].$done
			cmd:   #cluster.kubectl + [ "apply", "-n", "argocd", "-f", "-"]
			stdin: yaml.Marshal(#repositorySecret & {
				metadata: {
					name: "learn-argocd"
				}
				stringData: password: json.Unmarshal(command.setup["github"].stdout).token
			})
		}
		_applications: {
			"clusters": exec.Run & {
				$dep: command.setup["argocd"]["manifests"].$done
				cmd:  #cluster.kubectl + ["-n", "argocd", "apply", "-f", "config/clusters.yaml"]
			}
		}
	}
}

command: server: {
	password: {
		$dep: command["server"]["ui"]["wait"].$done
		wait: exec.Run & {
			cmd: ["/bin/sh", "-c", "while ! kubectl -n argocd get secret argocd-initial-admin-secret 2>&1 >/dev/null; do sleep 1; done "]
		}
		get: exec.Run & {
			$dep:   command["server"]["password"]["wait"].$done
			cmd:    #cluster.kubectl + ["-n", "argocd", "get", "secret", "argocd-initial-admin-secret", "-o", "json"]
			stdout: string
		}
		print: cli.Print & {
			p:    base64.Decode(null, json.Unmarshal(get.stdout)["data"]["password"])
			text: "username: admin\npassword \(p)"
		}
	}
	ui: {
		wait: exec.Run & {
			cmd:    #cluster.kubectl + [ "wait", "-n", "argocd", "--for=condition=ready", "pod", "-l", "app.kubernetes.io/name=argocd-server"]
			stdout: string
		}
		command: exec.Run & {
			$dep: command.server["ui"]["wait"].$done
			cmd:  #cluster.kubectl + ["-n", "argocd", "port-forward", "svc/argocd-server", "8080:443"]
		}
	}
}

command: clean: {
	rm: exec.Run & {
		cmd: ["k3d", "cluster", "delete", #cluster.name]
	}
}
