# Highflame Helm charts Values file

This folder contains the Helm charts values files for different Kubernetes services.

You can refer to these files and patch them with your customizations.

For detailed instructions on deploying the services, refer to the [Service Deployment Guide](https://docs.highflame.ai/docs/deployment/highflame-services).

Select the directory that matches your platform and update the `secrets` section with the appropriate values. For more information about service-specific environment variables, refer to [The variable list](../docs/service-vars.md).

---

# Configuring Secrets

Service-specific secrets are configured in the Helm values files.

A typical values configuration contains a section similar to:

```yaml
secrets:
  enabled: true
  secretData:
    KEY: "Value"
```

Update the values with the credentials and configuration required by the target environment.

For example:

```yaml
secrets:
  enabled: true
  secretData:
    DATABASE_URL: "<database-connection-string>"
    API_KEY: "<api-key>"
```

> **Security:** Do not commit production credentials, private keys, tokens, passwords, or other sensitive values to the repository unless the deployment architecture explicitly requires it.

Use your organization's approved secret-management mechanism whenever possible.

---

# Deploying Highflame Services

After the infrastructure and Kubernetes prerequisites are available:

1. Confirm that `kubectl` points to the intended cluster.
2. Select the correct platform directory under `helm-values/`.
3. Update the required Helm values.
4. Configure the required secrets.
5. Verify service-specific environment variables.
6. Deploy the services using the approved deployment procedure.
7. Validate the resulting Kubernetes resources.
8. Run the smoke tests.

Verify the active Kubernetes context:

```bash
kubectl config current-context
```

Verify cluster access:

```bash
kubectl get nodes
```

Verify the target namespace:

```bash
kubectl get namespace
```

---

# Kubernetes Validation

After deployment, inspect the workloads:

```bash
kubectl get pods -A
```

For a specific namespace:

```bash
kubectl -n <namespace> get pods
```

Check deployments:

```bash
kubectl -n <namespace> get deployments
```

Check services:

```bash
kubectl -n <namespace> get services
```

Check Helm releases:

```bash
helm list -A
```

For a failed pod, inspect its status:

```bash
kubectl -n <namespace> describe pod <pod-name>
```

View logs:

```bash
kubectl -n <namespace> logs <pod-name>
```

For multi-container pods:

```bash
kubectl -n <namespace> logs <pod-name> -c <container-name>
```

---
# Troubleshooting

## Kubernetes access problems

Check the current context:

```bash
kubectl config current-context
```

Check available contexts:

```bash
kubectl config get-contexts
```

Test access:

```bash
kubectl get nodes
```

---

## Helm deployment problems

List releases:

```bash
helm list -A
```

Inspect a release:

```bash
helm status <release-name> -n <namespace>
```

Render the chart before applying changes when possible:

```bash
helm template <release-name> <chart> -f <values-file>
```

For an existing release, inspect its values:

```bash
helm get values <release-name> -n <namespace>
```

---

## Pod startup problems

Check the pod:

```bash
kubectl -n <namespace> get pods
```

Describe it:

```bash
kubectl -n <namespace> describe pod <pod-name>
```

Check logs:

```bash
kubectl -n <namespace> logs <pod-name>
```

Check previous container logs when a container has restarted:

```bash
kubectl -n <namespace> logs <pod-name> --previous
```
