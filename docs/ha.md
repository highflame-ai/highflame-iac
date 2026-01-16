# HA Setup across the Cloud

## 🏗️ Deployment Architecture

This Highflame Gateway application deployment, including considerations and implications:

1. Standalone Mode

* Single-region deployment

* Suitable for development, test environments, or non-critical workloads

* No cross-region failover or redundancy

2. High Availability (HA) / Disaster Recovery (DR) Mode

* Active-Passive deployment across two different regions

* Designed for high uptime, fault tolerance, and business continuity

* Suitable for production

The HA deployment setup is strongly depend on the cloud we are choosing as the services provided by the cloud may different from one to another.

## 🌍 Multi-Region HA Deployment

In HA mode, the application is deployed across two cloud regions (e.g., `East US` and `West US`) for redundancy and disaster recovery.

### ✅ Prerequisites for HA

Both regions must support:

* Required VM sizes, managed services, and resources

* Replication mechanisms for stateful components

### 🔁 Active-Passive Model

* Primary region handles live traffic

* Secondary region remains on standby (warm)

* Failover is manual or automated via health checks

## ⚠️ Cloud Platform Considerations

### AWS Cloud

* AWS supports Aurora Global database, which can be distributed across regions. The failover is faster and can be managed with less effort

* AWS has a Global Accelerator for managing the load balancing between 2 regions

* Global accelerator supports only public endpoints, no private IP allocation

* The backend for the Global accelerator, which is an ALB ingress controller, must be a public ALB, not a private ALB

* Periodically simulate region failures, and validation of the DR setup can be done without deleting the resources

### Azure Cloud

* Azure doesn't support a global database, and it supports only reader deployment across the region. The failover will be difficult to manage via IAC as the reader becomes a standalone master node and detaches from the cluster once the failover happens. There is no option to join it back with the same cluster. The only option is to make the primary region the secondary region and create a new reader from the existing master (second region database server) in the old primary region

* Exploring a good solution for global load balancing...

* The simulation of the periodic DR recovery requires more work. It needs to recreate some resources, such as the Database server, and track it under the Iac by importing its statefile into the Terraform code (Only if we need ot manage it from the IaC).

# DR RunBook

## AWS Disaster Recovery (DR) Runbook

The DR setup is an `active-passive cluster` in 2 different regions, where the active region serves READ/WRITE traffic and the passive region can serve READ traffic. The switchover of passive to active can be set up as Auto or Manual. The swtichover may take 10 - 30 secs.

These are the steps we have to follow in the manual DR process

* Do failover in the Aurora Global DB - this will switch the primary node and standby node across the region, so the second region becomes read and write, and the first region will be read only

* Update the `Traffic dial` in the Global accelerator's `Endpoint groups` as below -  This can be done either via Terraform or AWS console.

    * `active region` - Traffic dial must be `100`

    * `passive region` - Traffic dial must be `0`


## Azure Disaster Recovery (DR) Runbook

The DR setup is an `active-passive cluster` in 2 different regions, where the active region serves READ/WRITE traffic and the passive region can serve READ traffic. The switchover of passive to active can be set up as Auto or Manual. The swtichover may take 10 - 60 secs.

The following steps are mandatory for the manual DR process

* Do manual failover in the Azure postgres DB - This will promote the reader postgres in the second region as a standalone primary node, and it will detach from the primary region 

* The region 1 database will no longer be useful as it can not be attached back to the existing primary node. to create anotehr reader in region 1, you have to manually setup the reader from the region 2 node to region 1. so the primary will be in region 2, and the reader will be in region 1.

* Update the application gateway ip / privatelink (`Fully-qualified domain name (FQDN) or IP address`) in the `Traffic Manager` > `Endpoints`. After a manual failover, noting that these changes typically reflect within 10-30 seconds