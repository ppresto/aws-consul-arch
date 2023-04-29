.PHONY: all init deploy plan destroy fmt clean
.PHONY: consul-install consul-use1 consul-usw2 awslb dataplane fake-service

OUTPUT=`terraform output -raw`

all: infra-deploy eks-connect consul-install metrics-install fortio-install fortio-run-loadtest
destroy: init metrics-clean consul-clean infra-clean

fmt:
	@terraform fmt -recursive

init: fmt
	@doormat login && eval $(doormat aws export -a aws_ppresto_test)
	@terraform init

infra-deploy: init
	@terraform apply -auto-approve

eks-connect:
	@source "../../../scripts/kubectl_connect_eks.sh" .
	@kubectl config use-context usw2-app1
	@kubectl cluster-info

consul-install:
	@terraform -chdir="../../../consul_helm_values" apply -auto-approve
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

fortio-run-loadtest:
	@../../../../terraform-aws-azure-load-test/deploy/reports/run.sh 300

metrics-clean:
	@-../../../../terraform-aws-azure-load-test/deploy/fortio-baseline/deploy.sh destroy
	@-../../../../terraform-aws-azure-load-test/deploy/fortio-consul/deploy.sh destroy
	@-../../../../terraform-aws-azure-load-test/deploy/deploy_helm.sh destroy

consul-clean: metrics-clean
	@-terraform -chdir="../../../consul_helm_values" destroy -auto-approve 

infra-clean:
	@terraform destroy -auto-approve 

clean:
	-rm -rf .terraform/
	-rm .terraform.lock.hcl
	-rm terraform.tfstate*