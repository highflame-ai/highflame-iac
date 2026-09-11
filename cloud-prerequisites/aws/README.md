# AWS Cloud setup for Highflame platform

The Highflame platform dependency configurations are managed here.

## References

### Cluster Autoscaler

- Permission setup [https://docs.aws.amazon.com/eks/latest/best-practices/cas.html](https://docs.aws.amazon.com/eks/latest/best-practices/cas.html)

### Fluent Bit
- Fluent Bit Helm chart: [https://github.com/fluent/helm-charts/tree/main/charts/fluent-bit](https://github.com/fluent/helm-charts/tree/main/charts/fluent-bit)
- Fluent Bit docs: [https://docs.fluentbit.io](https://docs.fluentbit.io/)
- EKS logging best practices: [https://docs.aws.amazon.com/eks/latest/best-practices/logging.html](https://docs.aws.amazon.com/eks/latest/best-practices/logging.html)
- CloudWatch output plugin: [https://docs.fluentbit.io/manual/pipeline/outputs/cloudwatch](https://docs.fluentbit.io/manual/pipeline/outputs/cloudwatch)
- IRSA: [https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)