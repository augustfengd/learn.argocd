// cue export -f application-b.cue --out yaml > application-b.yaml

import (
	"encoding/yaml"
)

apiVersion: "argoproj.io/v1alpha1"
kind:       "Application"
metadata: {
	name:      "appofapps.pure.manifests"
	namespace: "argocd"
	finalizers: ["resources-finalizer.argocd.argoproj.io"]
}
spec: {
	project: "default"
	source: {
		repoURL: "https://github.com/augustfengd/learn.argocd"
		path:    "manifests/yaml"
	}
	destination: {
		namespace: "appofapps-pure"
		server:    "https://kubernetes.default.svc"
	}
	syncPolicy: {
		syncOptions: ["CreateNamespace=true"]
		automated: {}
	}
}
