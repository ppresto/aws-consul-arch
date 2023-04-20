# aws-consul

This repo builds the required AWS Networking and EKS resources to run either self hosted or HCP Consul in a variety of architectures.

## Arch 1: Single EKS cluster with 3 Node Groups
This configuration creates an AWS EKS cluster with 3 Self Managed Node Groups.
- default:  Anything can be put here like a monitoring stack.
- consul:   Consul resources should be placed here
- services: All service mesh enabled services

### AWS Placement Groups
2 of these node groups (consul, services) are using [AWS Placement Groups](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-groups.html) with a `cluster` strategy for higher throughput performance.

### AWS - EKS Load Balancer Controller
The AWS Load Balancer Controller has been installed to enable internal NLB routing for Mesh Gateways.

## Getting Started

### Pre Reqs
- Consul Enterprise License copied to `./files/consul.lic`
- Setup shell with AWS credentials (need permission to build all networking, ec2, eks, & placement groups)
- Terraform 1.3.7+
- aws cli
- kubectl

### Provision Infrastructure
Use terraform to build infra
```
cd quickstart/infra_examples/1eks-selfmanaged-pg
terraform init
terraform apply -auto-approve
```

Connect to EKS using `scripts/kubectl_connect_eks.sh`.  Pass this script the path to the terraform state file used to provision the EKS cluster.  If cwd is ./1eks-selfmanaged-pg like above then this command would look like the following:
```
source ../../../scripts/kubectl_connect_eks.sh .
```
This script connects EKS and builds some useful aliases shown in the output.

## Install Consul
```
cd ../../../consul_helm_values
terraform init
terraform apply -auto-approve
```

### Update Anonymous policy
Add agent read access to anonymous policy.  This allows Prometheus access to the /agent/metrics endpoint.  The following script requires access to the EKS cluster running consul.  This will setup your local shell env to use Consul CLI and update tne anonymous policy with agent "read".
```
../scripts/setEKS-ConsulEnv-AnonPolicy.sh
```
## Setup Monitoring Stack
Metrics gathering is currently being configured outside of this repo. Verify you are connected to your EKS cluster and then run the following commands to clone the Metrics Stack (prometheus, grafana, fortio) repo.
```
cd ../.. # cd out of your current repo.
git clone https://github.com/ppresto/terraform-aws-azure-load-test.git
```

Setup the Stack (Prometheus, Grafana)
```
cd terraform-aws-azure-load-test
deploy/deploy_helm.sh
```
### Fortio loadtests
There are multiple test cases contained within a directory.
* fortio-baseline
* fortio-consul

Deploy a single test use case
```
cd fortio-baseline
deploy_all.sh
```

Undeploy the test use case by providing any value as a parameter (ex: delete)
```
cd fortio-baseline
deploy_all.sh delete
```



