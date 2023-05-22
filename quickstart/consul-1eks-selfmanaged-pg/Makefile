.PHONY: all init deploy plan destroy fmt clean
.PHONY: consul-install consul-use1 consul-usw2 awslb dataplane fake-service

K8S_CONTEXT=`terraform output -json usw2_projects | jq -r '.[]'`

all: infra-deploy eks-connect consul-install metrics-install run-fortio-tests
destroy: eks-connect metrics-clean consul-clean infra-clean

fmt:
	@terraform fmt -recursive

init: fmt
	@terraform init

infra-deploy: init
	@-terraform apply -auto-approve
	@sleep 5
	@terraform apply -auto-approve

eks-connect:
	@source "../../scripts/kubectl_connect_eks.sh" .
	@kubectl cluster-info
	@kubectl config use-context ${K8S_CONTEXT}

consul-install:
	@terraform -chdir="consul_helm_values" init
	@terraform -chdir="consul_helm_values" apply -auto-approve
	@echo "Login to Consul UI - https://"
	@kubectl -n consul get svc consul-ui -o json | jq -r '.status.loadBalancer.ingress[].hostname'
	@echo "Token"
	@kubectl -n consul get secrets consul-bootstrap-acl-token --template "{{ .data.token | base64decode }}"
	@echo

metrics-install:
	@../../metrics/deploy_helm.sh
	@../../metrics/fortio-tests/deploy.sh

run-fortio-tests:
	@../../metrics/reports/seq_http_tests.sh -k ${K8S_CONTEXT} -f ./reports
	@../../metrics/reports/seq_grpc_tests.sh -k ${K8S_CONTEXT} -f ./reports

run-fortio-tests-parallel:
	@../../metrics/reports/parallel_http_tests.sh -k ${K8S_CONTEXT} -f ./reports
	@../../metrics/reports/parallel_grpc_tests.sh -k ${K8S_CONTEXT} -f ./reports
run-fortio-tests-demo:
	@../../metrics/reports/parallel_http_tests.sh -k ${K8S_CONTEXT} -f ./reports -c2 -d600 -q100

metrics-clean:
	@-../../metrics/deploy_helm.sh -d
	@-../../metrics/fortio-tests/deploy.sh delete

consul-clean: eks-connect metrics-clean
	@-terraform -chdir="consul_helm_values" destroy -auto-approve 

infra-clean:
	@terraform destroy -auto-approve 

clean:
	-rm -rf .terraform/
	-rm .terraform.lock.hcl
	-rm terraform.tfstate*