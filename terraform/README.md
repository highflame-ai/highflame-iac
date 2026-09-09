**ℹ️ IMPORTANT NOTICE**

This Terraform configuration is designed for general cloud provider environments without any custom networking or VPC-level policies and single region deployment. 

If your organization enforces specific network or cloud provider policies, please fork this repository and adjust the Terraform code accordingly to ensure compliance with your organization's standards.

---

# Prerequisites

Before starting a deployment, ensure that the system used to manage the environment has the required tools installed.

## Required tools

* Terraform
* Helm v3
* `kubectl`
* The appropriate cloud provider CLI
* Git
* An editor or IDE for modifying configuration files

The system must also have access to the target Kubernetes cluster and the cloud account/project/subscription in which the infrastructure will be deployed.

### Kubernetes access

Verify that `kubectl` can communicate with the target cluster:

```bash
kubectl cluster-info
```

Verify that Helm is available:

```bash
helm version
```

Verify that Terraform is available:

```bash
terraform version
```

The exact Terraform and provider versions should be taken from the Terraform configuration and lock files in the repository rather than assumed from this README.

---

# Clone the Repository

Clone the repository to the system from which the deployment will be performed:

```bash
git clone https://github.com/highflame-ai/highflame-iac.git
cd highflame-iac
```

It is recommended to use a known release or approved branch when performing a production deployment rather than deploying an arbitrary development revision.

---

# Terraform Configuration

Terraform configuration is located under:

```text
terraform/
```

The directory is divided into:

```text
terraform/
├── cloud/
├── config/
├── modules/
└── README.md
```

## Cloud environments

Cloud-specific environment configurations are located under:

```text
terraform/cloud/
```

The current repository contains configurations for:

```text
terraform/cloud/
├── aws/
├── azure/
└── gcp/
```

Each provider contains an environment-specific directory.

For example:

```text
terraform/cloud/aws/<aws-account-id>/prod/
terraform/cloud/azure/<azure-subscription-id>/prod/
terraform/cloud/gcp/<gcp-project-id>/prod/
```

### Environment naming

`prod` is only an environment name. It does not have any special Terraform meaning.

You can rename the directory to an appropriate name for your environment, such as:

```text
dev
staging
qa
customer-a
production
```

If the environment directory is renamed, update the corresponding Terraform configuration that references the environment path/name.

---

# Terraform Stack Deployment Order

Terraform stacks should be applied in the intended dependency order.

A typical deployment follows:

```text
1. backend
      ↓
2. infra-setup
      ↓
3. infra-addons
      ↓
4. k8s-addons
      ↓
5. Helm services
```

Do not arbitrarily apply the stacks in parallel unless the dependencies between them have been verified.

## Initialize Terraform

Navigate to the required stack:

```bash
cd terraform/cloud/<provider>/<account-or-project>/<environment>/<stack>
```

Initialize Terraform:

```bash
terraform init
```

Review the configuration:

```bash
terraform plan
```

Apply the configuration:

```bash
terraform apply
```

Repeat this process for each Terraform stack in the required order.

> **Important:** Always review the `terraform plan` output before applying infrastructure changes, particularly when modifying an existing environment.

---

# Cloud Provider Configuration

## AWS

AWS deployments are organized under:

```text
terraform/cloud/aws/
```

The directory structure uses the AWS account identifier and environment name:

```text
terraform/cloud/aws/<aws-account-id>/<environment>/
```

The AWS configuration provisions the infrastructure required for the Highflame Kubernetes deployment.

Make sure the AWS CLI is authenticated against the intended account before running Terraform.

Verify the active account:

```bash
aws sts get-caller-identity
```

---

## Azure

Azure deployments are organized under:

```text
terraform/cloud/azure/
```

The configuration uses the Azure subscription identifier and environment name.

Before running Terraform, authenticate with Azure:

```bash
az login
```

Verify the active subscription:

```bash
az account show
```

If multiple subscriptions are available, select the intended subscription before deployment.

---

## Google Cloud

GCP deployments are organized under:

```text
terraform/cloud/gcp/
```

The configuration uses the GCP project identifier and environment name.

Authenticate with Google Cloud:

```bash
gcloud auth login
```

Verify the active project:

```bash
gcloud config get-value project
```

Set the intended project if necessary:

```bash
gcloud config set project <project-id>
```

---

# Terraform Modules

Reusable Terraform modules are located under:

```text
terraform/modules/
```

The current module structure contains provider-specific modules as well as Highflame-specific modules:

```text
terraform/modules/
├── aws/
├── azure/
├── gcp/
└── highflame/
```

These modules should generally be reused by environment configurations rather than duplicating resource definitions between environments.

When adding or modifying infrastructure, prefer updating the appropriate module and passing environment-specific configuration from the environment layer.

---

# Troubleshooting

## Terraform state or backend problems

Check the backend configuration:

```bash
terraform init
```

If the backend configuration has changed:

```bash
terraform init -reconfigure
```

Do not delete or recreate Terraform state without understanding the consequences.

---

# Environment-Specific Configuration

The repository intentionally separates reusable infrastructure from environment-specific configuration.

A typical environment should define:

* Cloud provider configuration
* Account/project/subscription
* Region
* Environment name
* Kubernetes cluster configuration
* Networking configuration
* Storage configuration
* Database configuration
* Cache configuration
* DNS configuration
* Highflame service configuration
* Authentication configuration
* LLM configuration
* Secrets

Avoid hard-coding environment-specific values inside reusable Terraform modules.

---

# Updating an Existing Environment

When modifying an existing deployment:

1. Check the current Git revision.
2. Confirm the target environment.
3. Confirm the cloud account/project/subscription.
4. Review the relevant Terraform configuration.
5. Review the relevant Helm values.
6. Run `terraform plan`.
7. Review the plan carefully.
8. Apply Terraform changes if required.
9. Deploy/update the affected Helm releases.
10. Verify Kubernetes resources.

For application-only changes where infrastructure is unchanged, Terraform may not need to be executed.

---

# Security Considerations

Infrastructure configuration can contain references to sensitive resources and credentials.

Follow these rules:

* Never commit plaintext production passwords.
* Never commit private keys.
* Never commit cloud access keys.
* Never commit database credentials.
* Never commit OAuth client secrets.
* Never commit API tokens.
* Review Terraform plans before applying changes.
* Verify the Kubernetes context before running destructive commands.
* Restrict access to Terraform state.
* Use approved secret-management systems for sensitive values.
* Review changes to IAM, networking, ingress, security groups, firewall rules, and Kubernetes RBAC carefully.

Remember that Terraform state can contain sensitive values even when those values are not present directly in `.tf` files. Protect the Terraform backend accordingly.
