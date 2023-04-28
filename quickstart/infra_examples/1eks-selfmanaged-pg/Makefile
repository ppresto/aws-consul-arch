.PHONY: all init deploy plan destroy fmt clean
.PHONY: consul consul-info consul-use1 consul-usw2 awslb dataplane fake-service

OUTPUT=`terraform output -raw`

all: deploy eks-connect consul-install metrics-install

fmt:
	@terraform fmt -recursive

init: fmt
	@doormat login && eval $(doormat aws export -a aws_ppresto_test)
	@terraform init

deploy: init
	@terraform apply -auto-approve

eks-connect:
	@source "../../../scripts/kubectl_connect_eks.sh" .
	@kubectl config use-context usw2-app1
	@kubectl cluster-info

consul-install: server consul-info

server:
	@terraform -chdir="../../../consul_helm_values" apply -auto-approve

consul-info:
	@echo "Login to Consul UI - https://"
	@kubectl -n consul get svc consul-ui -o json | jq -r '.status.loadBalancer.ingress[].hostname'
	@echo "Token"
	@kubectl -n consul get secrets consul-bootstrap-acl-token --template "{{ .data.token | base64decode }}"

metrics-install:
	@if [[ ! -d ../../../../terraform-aws-azure-load-test ]]; then git clone https://github.com/ppresto/terraform-aws-azure-load-test.git ../../../../; fi
	@../../../../terraform-aws-azure-load-test/deploy/deploy_helm.sh

fortio-install:
	@../../../../terraform-aws-azure-load-test/deploy/fortio-baseline/deploy.sh
	@../../../../terraform-aws-azure-load-test/deploy/fortio-consul/deploy.sh

fortio-run-loadtests:
	@../../../../terraform-aws-azure-load-test/deploy/reports/run.sh 300

metrics-clean:
	@../../../../terraform-aws-azure-load-test/deploy/fortio-baseline/deploy.sh destroy
	@../../../../terraform-aws-azure-load-test/deploy/fortio-consul/deploy.sh destroy
	@../../../../terraform-aws-azure-load-test/deploy/deploy_helm.sh destroy

consul-clean:
	@../../../../terraform-aws-azure-load-test/deploy/fortio-baseline/deploy.sh destroy
	@../../../../terraform-aws-azure-load-test/deploy/fortio-consul/deploy.sh destroy
	@../../../../terraform-aws-azure-load-test/deploy/deploy_helm.sh destroy
	@-terraform -chdir="../../../consul_helm_values" destroy -auto-approve 
	@- helm uninstall -n kube-system aws-load-balancer-controller eks/aws-load-balancer-controller
	@terraform destroy -auto-approve 

plan: init
	@terraform validate
	@terraform plan

destroy: init consul-clean

clean:
	-rm -rf .terraform/
	-rm .terraform.lock.hcl
	-rm terraform.tfstate*