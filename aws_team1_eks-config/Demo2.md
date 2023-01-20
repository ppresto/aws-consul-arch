# Demo

## Pre Reqs
Complete the following prereqs to perpare the env
### TFCB
* Create admin workspace and build/run Project workspaces (HCP, EC2, EKS1, EKS2) for init resources.
* Apply EKS1 and EKS2 config workspaces to deploy helm charts and bootstrap EKS clusters to HCP Consul.
### Browser
* Open HCP Tab
* Open TFCB Tab
  * Build HCP, eks1, eks2 workspaces
* Open Consul Tab
### VSCODE
* Open aws_team1_eks-config/templates/fake-service/release-apiv2/traffic-mgmt.yaml
* Open aws_team1_ec2/templates/vm-example/api-service.hcl
* Open aws_team1_ec2/templates/vm-example/start.sh
* Open aws_team1_eks-config/templates/fake-service/init-consul-config/intentions-api.yaml
### iTerm - VM Tab
Open VM Tab - cmd+shift+v 
```
ssh-add -L 
ssh-add /Users/patrickpresto/.ssh/hcp-consul
# use `ssh -A ubuntu@host` to pass key in mem
```

SSH to the bastion host.  Refresh workspace states (`aws_usw2_shared_hcp-consul, aws_usw2_dev_team1-ec2`) and then get the ssh command from `aws_usw2_dev_team1-ec2` outputs in TFCB.
```
ssh -J ubuntu@54.187.61.112 ubuntu@10.20.1.111
```

Deregister api service
```
cd /opt/consul/fake-service
./stop.sh
clear
```
### iTerm - EKS Tab
open terminal with iterm shortcut `Shift+Cmd+e` (EKS).
```
# Top Window
cd Projects/hcp/hcp-consul
dme # Doormat alias to update Terminal with AWS Creds
source ./scripts/kubectl_connect.sh

# Leave lower window alone for now
```
## Demo
Review the Current Environment
* [TFCB Workspaces](https://app.terraform.io/app/presto-projects/workspaces) Env Overview
* HCP Overview
* [Consul Overview](https://hcpc-cluster-presto.consul.328306de-41b8-43a7-9c38-ca8d89d06b07.aws.hashicorp.cloud/ui/~api-ns/hcpc-cluster-presto/services/api/intentions) (Vanilla)
### Deploy first service on VM
Start the api service in the VM environment.
```
cd /opt/consul/fake-service
sudo ./start.sh
#curl localhost:9091
```
Review
* `aws_team1_ec2/templates/vm-example/api-service.hcl`
* `aws_team1_ec2/templates/vm-example/start.sh`

### Deploy second service to EKS (multi-tenant K8s cluster)
The `web` service will need to talk to `api` hosted in the classic EC2 network
```
team1
kubectl apply -f aws_team1_eks-config/templates/fake-service/init-consul-config/
kubectl apply -f aws_team1_eks-config/templates/fake-service/release-web/
kubectl delete -f aws_team1_eks-config/templates/fake-service/init-consul-config/intentions-api.yaml
kubectl -n web get pods
```
REVIEW
* Namespaces (web) - Mirroring K8s namespaces
* Service Authentication

### Verify `web` can communicate to `api` its upstream 
```
echo "http://$(kubectl get svc team1-ingress-gateway -n consul -o json | jq -r '.status.loadBalancer.ingress[].hostname'):8080/ui"
```
### Why is this broken?
* Web Topology Tab (No Upstream)
* Intentions Tab (No AuthZ)
* Apply Intention
```
kubectl apply -f  aws_team1_eks-config/templates/fake-service/init-consul-config/intentions-api.yaml
```
Review
* `api` Topology tab
* Refresh URL

## The Shared EKS Cluster is growing. 
The API team is adopting K8s and wants to deploy a new version of `api` on the shared EKS cluster
* Migrate from EC2 to EKS with no downtime (to downstream services like `web`)

### Watch `web` requests to `api` during this migration using a curl script
EKS Tab - Lower Window
```
./scripts/call_ingress_web.sh
```

### Now we are ready to Deploy api-v2 to EKS
```
kubectl apply -f aws_team1_eks-config/templates/fake-service/release-apiv2
ka get pods -l service=fake-service
```
REVIEW
* `api` Routing Tab
* Traffic Splitter

Move to 50/50, then 100%...
```
kubectl apply -f aws_team1_eks-config/templates/fake-service/release-apiv2/traffic-mgmt.yaml
```
* Use cases: Canary , Blue/Green Deployments
* Migration Complete (No downtime)

## The API team is being asked for offer new payment functionality
This means they need access to services within the secured PCI network.

### Deploy api-v3 which will have an upstream service called payments
```
kubectl apply -f aws_team1_eks-config/templates/fake-service/release-apiv3
```
REVIEW
* `api` Routing Tab
* Service Router
  * Path Routing (supports GRPC)
  * Header based routing
  * Retry Logic

### Validate `api-v3` requests to `payments`
Enable ModHeaders in Chrome with header `baggage: '.*version=3.*'`
* Review Fake Service URL to show traffic routed by header to pci/payments/payments (failing)

## Deploy pci/payments/payments
```
team2
kubectl apply -f aws_team2_eks-config/templates/fake-service/init-consul-config/
kubectl apply -f aws_team2_eks-config/templates/fake-service/release-payments/
kp get pods -l service=fake-service
team1
kc delete pod -l component=mesh-gateway
team2
kp get pods -l service=fake-service
```
REVIEW
* Refresh Fake Service URL
* aws_team2_eks-config/templates/fake-service/init-consul-config
  * ap_exportedServices.yaml
  * intentions.yaml

## END
### Option DNS Lookups from VM
DNS Service Lookups:
```
dig @127.0.0.1 -p 8600 consul.service.consul
dig consul.service.consul

# SRV records
dig consul.service.consul SRV
dig api.service.api.ns.default.ap.usw2.dc.consul SRV
dig _api._tcp.service.api.ns.default.ap.usw2.dc.consul SRV
# with Tag 'v1'
dig _api._v1.service.api.ns.default.ap.usw2.dc.consul SRV

# Connect
dig api.connect.api.ns.default.ap.usw2.dc.consul
dig api.connect.api.ns.default.ap.usw2.dc.consul SRV

# Ingress Services
dig web.ingress.web.ns.default.ap.usw2.dc.consul
dig web.ingress.web.ns.default.ap.usw2.dc.consul SRV

# Service Virtual IP (Used by Transparent Proxy)
dig api.virtual.api.ns.default.ap.usw2.dc.consul
#tag
dig v1.api.service.api.ns.default.ap.usw2.dc.consul
```

DNS Node Lookup
```
dig ip-10-20-1-111.node.usw2.consul
```
## Clean up - Delete deployments

```
team1
kubectl delete -f aws_team1_eks-config/templates/fake-service/release-apiv3/api-v3.yaml
kubectl delete -f aws_team1_eks-config/templates/fake-service/release-apiv3/ap_exortedServices.yaml

kubectl delete -f aws_team1_eks-config/templates/fake-service/release-apiv2/api-v2.yaml
kubectl delete -f aws_team1_eks-config/templates/fake-service/release-apiv3/
kubectl delete -f aws_team1_eks-config/templates/fake-service/release-apiv2/
kubectl delete -f aws_team1_eks-config/templates/fake-service/release-web
kubectl delete -f aws_team1_eks-config/templates/fake-service/init-consul-config
team2
kubectl delete -f aws_team2_eks-config/templates/fake-service/release-payments
kubectl delete -f aws_team2_eks-config/templates/fake-service/init-consul-config
kc get po
```

Set Consul Environment.  Pull HTTP_ADDR and TOKEN from TFCB.
```
source ./scripts/setConsulEnv.sh <CONSUL_TOKEN>
consul namespace delete web
```
## QuickStart - Deploy mesh defaults and services
```
team1
kubectl apply -f aws_team1_eks-config/templates/fake-service/init-consul-config
kubectl apply -f aws_team1_eks-config/templates/fake-service/release-web
kubectl apply -f aws_team1_eks-config/templates/fake-service/release-apiv2
kubectl apply -f aws_team1_eks-config/templates/fake-service/release-apiv3

team2
kubectl apply -f aws_team2_eks-config/templates/fake-service/init-consul-config
kubectl apply -f aws_team2_eks-config/templates/fake-service/release-payments
```
## Troubleshooting - Consul CLI
Setup the terminal to connect to Consul.  Install consul locally as a prereq and get a Consul Token.
```
source scripts/setConsulEnv.sh <CONSUL_TOKEN>
```

Read `api` configuration settings from a namespace in the default partition
```
consul config read -kind service-defaults -name api -namespace api
consul config read -kind service-router -name api -namespace api
consul config read -kind service-resolver -name api -namespace api
consul config read -kind service-splitter -name api -namespace api
consul config read -kind service-intentions -name api -namespace api
```

Read `payments` config from the pci partition
```
consul config read -kind service-intentions -name payments -namespace payments -partition pci
```
### On EKS
Team1 may have the consul agent deployed.  If so use that container to run Consul CLI commands.

```
team1
kc exec -it team1-client-k7lfc -c consul -- consul config read -kind service-defaults -name api -namespace api
```

## Troubleshooting - EKS CRD's
kubectl -n consul describe servicedefaults api
kubectl -n consul describe servicerouters api
kubectl -n consul describe serviceresolvers api
kubectl -n consul describe servicesplitters api
kubectl -n consul describe serviceintentions api
```