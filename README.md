# aws-consul

This repo builds the required AWS Networking and EKS resources to run either self hosted or HCP Consul in a variety of architectures.

## Single EKS cluster with 3 Node Groups
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
## Setup Monitoring Stack
Metrics gathering is currently being configured outside of this repo. Verify you are connected to your EKS cluster and then run the following commands to setup the Metrics Stack (prometheus, grafana, fortio)
```
git clone https://github.com/ppresto/terraform-aws-azure-load-test.git
cd terraform-aws-azure-load-test
deploy/deploy_all.sh
```

