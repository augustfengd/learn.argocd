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
		source:  _#manifestsSource | _#helmSource | _#pluginSource
		destination: {
			namespace: string
			server:    "https://kubernetes.default.svc"
		}
		syncPolicy: {
			syncOptions: ["CreateNamespace=true"]
			automated: {}
		}
	}
	_#manifestsSource: {
		repoURL:        string
		targetRevision: string
		path:           string
		directory?: {
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
	metadata: name: "jsonnet"
	spec: source: {
		repoURL:        "https://github.com/augustfengd/learn-argocd"
		path:           "manifests/jsonnet"
		targetRevision: "main"
		directory: {
			jsonnet: tlas: [{name: "name", value: "foobar"}]
		}
	}
	spec: destination: namespace: "jsonnet"
}

apps: "appofapps.pure": _#argocdApplication & {
	metadata: name: "appofapps.pure"
	spec: source: {
		repoURL:        "https://github.com/augustfengd/learn-argocd"
		path:           "manifests/appofapps.pure"
		targetRevision: "main"
	}
	spec: destination: namespace: "appofapps-pure"
}

apps: "appofapps.mixed": _#argocdApplication & {
	metadata: name: "appofapps.mixed"
	spec: source: {
		repoURL:        "https://github.com/augustfengd/learn-argocd"
		path:           "manifests/appofapps.mixed"
		targetRevision: "main"
	}
	spec: destination: namespace: "appofapps-mixed"
}
