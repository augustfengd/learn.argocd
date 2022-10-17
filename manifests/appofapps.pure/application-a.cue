// cue export -f application-a.cue -o application-a.yaml

import (
	"encoding/yaml"
)

apiVersion: "argoproj.io/v1alpha1"
kind:       "Application"
metadata: {
	name:      "appofapps.pure.chart"
	namespace: "argocd"
	finalizers: ["resources-finalizer.argocd.argoproj.io"]
}
spec: {
	project: "default"
	source: {
		repoURL:        "https://helm.github.io/examples"
		targetRevision: "0.1.0"
		chart:          "hello-world"
		helm: values: yaml.Marshal({fullnameOverride: "hello-world"})
	}
	destination: {
		namespace: "appofapps-pure"
		server:    "https://kubernetes.default.svc"
	}
	syncPolicy: {
		syncOptions: ["CreateNamespace=true"]
	}
}
