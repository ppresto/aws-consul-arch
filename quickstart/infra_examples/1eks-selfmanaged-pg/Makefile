.PHONY: all init deploy plan destroy fmt clean
.PHONY: consul-install consul-use1 consul-usw2 awslb dataplane fake-service

OUTPUT=`terraform output -raw`

all: infra-deploy eks-connect consul-install
destroy: init metrics-clean consul-clean infra-clean

fmt:
	@terraform fmt -recursive

init: fmt
	@terraform init

infra-deploy: init
	@-terraform apply -auto-approve

eks-connect:
	@source "../../../scripts/kubectl_connect_eks.sh" .
	@kubectl config use-context usw2-app1
	@kubectl cluster-info

consul-install:
	@terraform -chdir="consul_helm_values" init
	@terraform -chdir="consul_helm_values" apply -auto-approve
	@echo "Login to Consul UI - https://"
	@kubectl -n consul get svc consul-ui -o json | jq -r '.status.loadBalancer.ingress[].hostname'
	@echo "Token"
	@kubectl -n consul get secrets consul-bootstrap-acl-token --template "{{ .data.token | base64decode }}"

metrics-clean:
	@-../../../../terraform-aws-azure-load-test/deploy/fortio-tests/deploy.sh destroy
	@-../../../../terraform-aws-azure-load-test/deploy/deploy_helm.sh destroy

consul-clean: metrics-clean
	@-terraform -chdir="consul_helm_values" destroy -auto-approve 

infra-clean:
	@terraform destroy -auto-approve 

clean:
	-rm -rf .terraform/
	-rm .terraform.lock.hcl
	-rm terraform.tfstate*