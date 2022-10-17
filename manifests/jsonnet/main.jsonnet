function(name) {
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: name,
    labels: {
      app: name,
    },
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: {
        app: 'foobaz',
      },
    },
    template: {
      metadata: {
        labels: {
          app: name,
        },
      },
      spec: {
        containers: [
          {
            image: 'nginx',
            name: 'nginx',
            ports: [
              {
                containerPort: 80,
              },
            ],
          },
        ],
      },
    },
  },
}
