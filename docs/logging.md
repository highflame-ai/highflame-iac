# Service Logging & Monitoring Setup

This document outlines the configuration of logging and monitoring systems deployed in an Amazon EKS (Elastic Kubernetes Service) cluster. The setup includes:

- **Fluent Bit** for log forwarding
- **Amazon CloudWatch Logs** as the log storage backend
- **Prometheus** for metrics scraping
- **Grafana** for visualization

---

## 📄 Logging Architecture (AWS)

### 🔧 Fluent Bit

Fluent Bit is deployed as a **DaemonSet** in the EKS cluster to collect logs from each node. It is configured to:

- Tail logs from `/var/log/containers/*.log` for each microsevrice deployed in the EKS
- Parse Kubernetes logs using the Kubernetes filter and create individual log group with the highflame service name
- Forward logs to **Amazon CloudWatch Logs** under the respective log stream name, the name match with the highflame service name

**IAM Permissions** for Fluent Bit (via IRSA) are configured to allow writing to CloudWatch Logs.

### 🔗 CloudWatch Logs Integration

Logs are sent to **CloudWatch Log Groups** in the following format:

`PROJECT_NAME-PROJECT_ENV-eks-service-log`. where,

- `PROJECT_NAME` is the `project_name` variable passing in the terraform code

- `PROJECT_ENV` is the `project_env` variable passing in the terraform code

within the log group, there will be one log stream representing all microservices as the diagram below.

![log streams](./img/aws-log-stream.png)


## 📄 Logging Architecture (Azure)

### 🔧 Fluent Bit

Fluent Bit a managed solution from azure is deployed as a **DaemonSet** in the AKS cluster to collect logs from each node. It is configured to:

- Fetch the logs from the `/var/log/containers/*.log` for each microsevrice deployed in the AKS
- Filter the logs from the deployed namespace only
- Parse Kubernetes logs using the Kubernetes filter and create individual log group with the highflame service name
- Forward logs to **Azure log analytics workspace**

### 🔗 Analytics workspace Logs Integration

Logs are sent to **Analytics workspace** in the following format:

`PROJECT_NAME-PROJECT_ENV-aks-service-log`. where,

- `PROJECT_NAME` is the `project_name` variable passing in the terraform code

- `PROJECT_ENV` is the `project_env` variable passing in the terraform code

---

# 📊 Monitoring Architecture

### 🔧 Prometheus

Prometheus is deployed as a **DaemonSet** in the EKS cluster with the following features:

- Scraping metrics from:

  - kubelet

  - cAdvisor

  - CoreDNS

  - Node exporter

**Persistent storage** is enabled via EBS volumes.

### 📈 Grafana

Grafana is deployed with:

- Prometheus as the data source

- Pre-built dashboards for:

  - kubernetes Deployment Dashboard Overall

  - Kubernetes Deployment Overview

  - Kubernetes Deployments

  - Kubernetes Node Monitoring

- Authentication via basic auth

#### Dashboards

###### 📈 kubernetes Deployment Dashboard Overall

![grafana-dashboard](./img/grafana-dashboard-a.png)

###### 📈 Kubernetes Deployment Overview

![grafana-dashboard](./img/grafana-dashboard-b.png)

###### 📈 Kubernetes Deployments

![grafana-dashboard](./img/grafana-dashboard-c.png)

###### 📈 Kubernetes Node Monitoring

![grafana-dashboard](./img/grafana-dashboard-d.png)

---

## 🔐 Security & Access

- Grafana access can be exposed via LoadBalancer or through an Ingress controller with HTTPS.

---