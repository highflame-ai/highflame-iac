# Highflame Helm charts Values file

This folder contains the Helm charts values files for different Kubernetes services.

You can refer to these files and patch them with your customizations.

For detailed instructions on deploying the services, refer to the [Service Deployment Guide](https://docs.highflame.ai/docs/deployment/highflame-services).

Select the directory that matches your platform and update the `secrets` section with the appropriate values. For more information about service-specific environment variables, refer to [The variable list](../docs/service-vars.md).

```code
secrets:
  enabled: true
  secretData:
    KEY: "Value"
```