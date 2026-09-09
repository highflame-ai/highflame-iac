# highflame-iac

Infrastructure-as-Code repository for deploying and managing the Highflame platform across supported cloud providers and Kubernetes platforms.

This repository contains the infrastructure definitions, Terraform modules, Kubernetes/Helm configuration, deployment scripts, smoke tests, and supporting configuration required to provision the infrastructure and deploy Highflame services.

## Overview

The repository is organized into several major areas:

* **Terraform** — Cloud infrastructure and Kubernetes prerequisites.
* **Helm values** — Platform-specific values files for Highflame services.
* **Scripts** — Deployment and operational helper scripts.
* **Smoke tests** — Post-deployment validation.
* **Documentation** — Deployment and configuration documentation.
* **Air-gapped poc evaluation** — A separate deployment path for evaluating Highflame in an air-gapped poc environment.

The repository currently provides configuration for:

| Platform     | Kubernetes |
| ------------ | ---------- |
| AWS          | EKS        |
| Azure        | AKS        |
| Google Cloud | GKE        |

The repository also contains Terraform modules for AWS, Azure, GCP, and Highflame-specific resources.

---

# Deployment Architecture

A typical deployment consists of two major stages:

1. **Provision the required cloud and Kubernetes infrastructure using Terraform or manually.**
2. **Deploy Highflame services to Kubernetes using Helm.**

```code
Do not copy the terraform code directly into your IaC code or run them against your cloud environment without first reviewing and patching them to match your account, networking, and security requirements. this is purely for your reference
```

The Terraform configuration is separated into multiple stacks so that infrastructure can be provisioned in a controlled order.

For example, the AWS environment currently contains the following Terraform stacks:

```text
terraform/cloud/aws/<account-id>/<environment>/
├── backend/
├── infra-setup/
├── infra-addons/
└── k8s-addons/
```

These stacks have the following responsibilities:

| Stack          | Purpose                                                |
| -------------- | ------------------------------------------------------ |
| `backend`      | Configures the backend used to store Terraform state   |
| `infra-setup`  | Provisions the primary cloud infrastructure            |
| `infra-addons` | Provisions additional infrastructure components        |
| `k8s-addons`   | Installs Kubernetes addons and Highflame prerequisites |

The same overall approach is used for the supported cloud platforms, although the implementation differs by provider.

---

# Helm Values

Helm configuration is stored under:

```text
helm-values/
```

The values are separated by Kubernetes platform:

```text
helm-values/
├── AKS/
├── EKS/
└── GKE/
```

Each platform directory contains service-specific Helm values templates.

For example:

```text
helm-values/EKS/
├── highflame-admin-helm-values-tmpl.yml
├── highflame-authn-helm-values-tmpl.yml
├── highflame-authz-helm-values-tmpl.yml
├── highflame-cerberus-helm-values-tmpl.yml
├── ...
└── highflame-studio-helm-values-tmpl.yml
```

---

# Selecting the Correct Helm Values

Before deploying the services, select the directory corresponding to the Kubernetes platform:

```text
EKS → helm-values/EKS/
GKE → helm-values/GKE/
AKS → helm-values/AKS/
```

Do not use values from another platform unless the differences have been explicitly reviewed.

The Helm values templates are intended to be customized for the target environment.

For detailed instructions on deploying the services, refer to the [Service Deployment Guide](https://docs.highflame.ai/docs/deployment).

For service-specific environment variables, refer to the [Highflame Service Variables](https://github.com/highflame-ai/highflame-iac/blob/main/docs/service-vars.md).

---

# Recommended Deployment Workflow

A standard deployment should follow this sequence:

```text
┌──────────────────────────┐
│ Clone highflame-iac      │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│ Configure cloud access   │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│ Select environment       │
│ and platform             │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│ Configure Terraform      │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│ terraform init / plan    │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│ Apply Terraform stacks   │
│ in dependency order      │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│ Configure Helm values    │
│ and secrets              │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│ Deploy Highflame         │
│ services with Helm       │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│ Validate Kubernetes      │
│ resources and services   │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│ Run smoke tests          │
└──────────────────────────┘
```

---

# Operational Checklist

Before deployment:

* [ ] Correct cloud account/project/subscription selected
* [ ] Correct Kubernetes context selected
* [ ] Correct environment selected
* [ ] Terraform initialized
* [ ] Terraform configuration reviewed
* [ ] `terraform plan` reviewed
* [ ] Required cloud resources available
* [ ] Required Kubernetes addons installed
* [ ] Correct Helm values selected
* [ ] Required secrets configured
* [ ] Required service environment variables configured

After deployment:

* [ ] All expected namespaces exist
* [ ] All expected pods are running
* [ ] Deployments are available
* [ ] Services have expected endpoints
* [ ] Ingress/load balancer is healthy
* [ ] Authentication is working
* [ ] Required external dependencies are reachable
* [ ] Highflame services can communicate with each other
* [ ] Smoke tests pass

---

# License

This repository is licensed under the MIT License.

See [LICENSE](./LICENSE) for the full license text.

--- 

# Reference

[Highflame Overwatch](./docs/overwatch.md)

[Highflame Service Variables](./docs/service-vars.md)

[Models Region Availability](./docs/model-region-availability.md)