package main

_#argocdApplication: {
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "Application"
	metadata: {
		name:      string
		namespace: "argocd"
		finalizers: ["resources-finalizer.argocd.argoproj.io"]
	}
	spec: {
		project: "default"
		source:  _#yamlSource | _#helmSource | _#jsonnetSource | _#pluginSource
		destination: {
			namespace: string
			server:    "https://kubernetes.default.svc"
		}
		syncPolicy: syncOptions: ["CreateNamespace=true"]
	}
	_#yamlSource: {
		repoURL:        string
		targetRevision: string
		path:           string
	}

	_#jsonnetSource: {
		repoURL:        string
		targetRevision: string
		path:           string
		directory: {
			jsonnet: {
				tlas?: [{
					name:  string
					value: string
				}]
			}
		}
	}

	_#helmSource: {
		repoURL:        string
		targetRevision: string
		helm: {
			skipCrds: bool | *false
			values:   string
		}
		chart: string
	}

	_#pluginSource: {
		repoURL:        string
		targetRevision: string
		plugin: env: [...{name: string, value: string}]
		name: string
	}
}

apps: jsonnet: _#argocdApplication & {
	metadata: name: "jsonnet-foobar"
	spec: source: {
		repoURL:        "https://github.com/augustfengd/learn-argocd"
		path:           "manifests/jsonnet"
		targetRevision: "main"
		directory: {
			jsonnet: tlas: [{name: "name", value: "foobar"}]
		}
	}
	spec: destination: namespace: "jsonnet-foobar"
}

apps: "appofapps": _#argocdApplication & {
	metadata: name: "jsonnet-foobar"
	spec: source: {
		repoURL:        "https://github.com/augustfengd/learn-argocd"
		path:           "manifests/jsonnet"
		targetRevision: "main"
		directory: {
			jsonnet: tlas: [{name: "name", value: "foobar"}]
		}
	}
	spec: destination: namespace: "jsonnet-foobar"
}

