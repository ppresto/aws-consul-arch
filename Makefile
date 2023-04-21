.PHONY: all init deploy plan destroy fmt clean
.PHONY: consul consul-admin consul-user consul-user-apigw consul-clean consul-admin-clean consul-user-clean consul-user-redeploy

OUTPUT=`terraform output -raw -state quickstart/infra_examples/2hcp-2eks-2ec2/terraform.tfstate`

all: deploy consul

init: fmt
	@doormat login && eval $(doormat aws export -a aws_ppresto_test)
	@terraform init -state quickstart/infra_examples/2hcp-2eks-2ec2/terraform.tfstate

deploy: init
	@terraform apply -auto-approve -state quickstart/infra_examples/2hcp-2eks-2ec2/terraform.tfstate
	@sleep 5
	@terraform apply -auto-approve -state quickstart/infra_examples/2hcp-2eks-2ec2/terraform.tfstate
	@source ./scripts/kubectl_connect_eks.sh quickstart/infra_examples/2hcp-2eks-2ec2/
	@kubectl config current-context

consul: consul-use1 consul-usw2

consul-use1:
	@scripts/setHCP-ConsulEnv-use1.sh
	@echo Pausing for admin cluster consul initialisation
	@sleep 180

consul-usw2:
	@scripts/setHCP-ConsulEnv-usw2.sh
	@echo Pausing for user cluster consul initialisation
	@sleep 180


plan: init
	@terraform validate
	@terraform plan

destroy: init consul-clean
	@terraform destroy -auto-approve

fmt:
	@terraform fmt -recursive

clean:
	-rm -rf .terraform/
	-rm .terraform.lock.hcl
	-rm terraform.tfstate*