{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    labels: {
      app: 'foobaz',
    },
    name: 'foobaz',
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
          app: 'foobaz',
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
