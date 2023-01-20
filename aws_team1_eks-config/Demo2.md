# Demo

## Prep
* Open HCP Tab
* Open TFCB Tab
  * Build HCP, eks1, eks2 workspaces
* Open Consul Tab
* Open VSCODE Tab ./aws_team1_eks-config/templates/fake-service/release-apiv2/traffic-mgmt.yaml

### Connect to EKS Clusters
```
#open terminal with iterm shortcut `Shift+Cmd+e` (EKS)
# `Shift+Cmd+v` (VM)
cd Projects/hcp/hcp_consul
dme # Doormat alias to update Terminal with AWS Creds
source ./scripts/kubectl_connect.sh
```

### Configure mesh and start services
Be sure the consul helm chart to install the agent has been deployed.  Then configure the initial defaults and start the web service.
```
team1
kubectl apply -f aws_team1_eks-config/templates/fake-service/init-consul-config/
kubectl apply -f aws_team1_eks-config/templates/fake-service/release-web/
```

### Verify web service is running
web will expect the api service to be running on the EC2 instances.  Lets check that these are running in the Consul UI.  If not ssh to the host and start the api fake-service.
```
ssh -J ubuntu@35.88.192.93 ubuntu@10.20.1.111  #Get this from workspace 'aws_usw2_dev_team1-ec2' outputs
sudo su -
cd /opt/consul/fake-service
./start.sh
```
### Remove Intension if desired for demo
Verify default/web -> default/api Intention (delete to manually show intentions during demo)
```
team1
kubectl delete -f aws_team1_eks-config/templates/fake-service/init-consul-config/intentions-api.yaml
```
Optional: Apply intention as CRD and show in UI
```
kubectl apply -f  aws_team1_eks-config/templates/fake-service/init-consul-config/intentions-api.yaml
```

### Open Fake-service URL.
```
echo "http://$(kubectl get svc team1-ingress-gateway -n consul -o json | jq -r '.status.loadBalancer.ingress[].hostname'):8080/ui"
```

## Show api version 1
## Deploy api-v2
The terraform workspace should have deployed api-v2, but no the splitter (traffic-mgmt.yaml).  Review the configuration and appy 50/50 split. 
Verify UI then run...
```
kubectl apply -f aws_team1_eks-config/templates/fake-service/release-apiv2
kubectl get pods -l service=fake-service
```
Move to 100%...

## Deploy api-v3
```
kubectl apply -f aws_team1_eks-config/templates/fake-service/release-apiv3
```


## Review Current Environment
* Walk through [TFCB Workspaces](https://app.terraform.io/app/presto-projects/workspaces)
* HCP, AWS VPC/TG, EKS cluster (Consul, and services)
* [Show Consul Dashboard](https://hcpc-cluster-presto.consul.328306de-41b8-43a7-9c38-ca8d89d06b07.aws.hashicorp.cloud/ui/~api-ns/hcpc-cluster-presto/services/api/intentions) (consul + web + api services)
  * Services -> api  - vm,v1 tags, Intentions

## Fake-Service App
Show Terminal sessions to EC2 to see api svc.  
Show current K8s cluster pods to see web.
```
kubectl get pods -A -l service=fake-service
```
* Show Fake Service URL - LB across EC2 (onprem/legacy/brownfield)


## Deploy api-v2 : Migration to EKS
This will deploy api-v2 pod, and apply traffic rules to route 100% to api-v1.
```
kubectl apply -f ./release-v2
sleep 2
kubectl get pods -l service=fake-service
```
* Review Fake Service URL
* Review api service routing in Consul UI.

Phase traffic over to api-v2.
* Update ./release-v2/traffic-mgmt.yaml (split 20/50/100)
```
kubectl apply -f release-v2/traffic-mgmt.yaml
```

## Deploy api-v3 : Show integration testing
This will deploy api-v3 pod, and apply traffic rules to route baggage header "version=2" to v3.
```
kubectl apply -f ./release-v3
sleep 1
kubectl get pods -l service=fake-service
```
* Review Fake Service URL
* Review api service routing in Consul UI.

Enable ModHeaders in Chrome.  Add baggage header with value: 'version=2'
Reload Fake Service URL to show traffic routing by header.

## Clean up
```
team1
kubectl delete -f aws_team1_eks-config/templates/fake-service/release-apiv3/api-v3.yaml
kubectl delete -f aws_team1_eks-config/templates/fake-service/release-apiv3/ap_exortedServices.yaml

kubectl delete -f aws_team1_eks-config/templates/fake-service/release-apiv2
kubectl delete -f aws_team1_eks-config/templates/fake-service/release-web
kubectl delete -f aws_team1_eks-config/templates/fake-service/init-consul-config
team2
kubectl delete -f aws_team2_eks-config/templates/fake-service/release-payments
kubectl delete -f aws_team2_eks-config/templates/fake-service/init-consul-config

source scripts/setConsulEnv.sh <CONSUL_TOKEN>
consul namespace delete api
consul namespace delete web
consul namespace delete payments

```
## Quick Deployment
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
## Troubleshooting
Read consul configuration settings from the CLI
```
source scripts/setConsulEnv.sh <CONSUL_TOKEN>
consul config read -kind service-defaults -name api
consul config read -kind service-router -name api
consul config read -kind service-resolver -name api
consul config read -kind service-splitter -name api
consul config read -kind service-intentions -name api
```
List and Delete work the same as Read.
Write examples are in EC2:/opt/consul/fake-service/start.sh

Read consul config from CRD
```
kubectl describe servicedefaults api
kubectl describe servicerouters api
kubectl describe serviceresolvers api
kubectl describe servicesplitters api
kubectl describe serviceintentions api
```