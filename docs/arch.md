## Architecture Diagram

This architecture diagram represents the deployment the Highflame AI Gateway Application, highlighting the infrastructure components, their relationships. It demonstrates how the deployment leverages Cloud services and resources for reliability, scalability, security, and cost-effectiveness.

![Highflame Infra](./img/architecture.png)

## Cross Region Architecture Diagram (AWS Specific)

Highflame AI Gateway can be deployed in cross region if the cloud provider meets the cross region HA requirements. The below diagram represents the cross region deployment of Highflame AI Gateway in AWS.

**ℹ️ IMPORTANT NOTICE**

The Terraform doesn't support the cross region deployment. If you are choosing cross region deployment, then please fork this repository and adjust the Terraform code accordingly to ensure that the following resources configured properly

* `AWS Application Load Balancer` cross region dns based failover setup, you can find the offical docs [here](https://docs.aws.amazon.com/whitepapers/latest/real-time-communication-on-aws/cross-region-dns-based-load-balancing-and-failover.html)

### Before you start

Achieving HA comes at a cost. The environment requirements are sizable as each component needs to be multiplied, which comes with additional actual and maintenance costs. you can achieve distributed environments in different regions by accepting the following considerations

* Most of the routes are region specific, for example `bedrock models`, If the region 1 goes down then the bedrock in that region is not accessible even our Highflame is available in the second region. So the route should be always region specific

* The Database won't be in sync, each cluster will have its own data and stored separately

* Each cluster must have same sets of gateweay and routes with api keys with exact same name. currently this need to be set manually from the UI

* The Cloud provider need to support DNS specific health check and route traffic to both cluster (Route53 or Global loadbalancer)

![Highflame AWS HA Infra](./img/aws-ha-architecture.png)

## Networking Diagram

The following diagram illustrates the key networking components, including VPCs, firewall, load balancers, and compute resources.

![Highflame Network](./img/networking.png)

## 🔒 Security Considerations

- All external inbound and outbound traffic is encrypted (HTTPS, TLS 1.2+)
- IAM policies enforce least privilege
- Application Logs enabled for monitoring and debugging
- Firewall open only required ports for traffic