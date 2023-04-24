.PHONY: all init deploy plan destroy fmt clean
.PHONY: consul consul-use1 consul-usw2

OUTPUT=`terraform output -raw -state quickstart/infra_examples/2hcp-2eks-2ec2/terraform.tfstate`

all: deploy consul

init: fmt
	@doormat login && eval $(doormat aws export -a aws_ppresto_test)
	@terraform -chdir="quickstart/infra_examples/2hcp-2eks-2ec2" init

deploy: init
	@-terraform -chdir="quickstart/infra_examples/2hcp-2eks-2ec2" apply -auto-approve
	@sleep 30
	@terraform -chdir="quickstart/infra_examples/2hcp-2eks-2ec2" apply -auto-approve
	@source ./scripts/kubectl_connect_eks.sh quickstart/infra_examples/2hcp-2eks-2ec2/
	@kubectl config use-context usw2-app1
	@kubectl cluster-info 
	@terraform -chdir="consul_helm_values" apply -auto-approve

consul: consul-use1 consul-usw2

consul-use1:
	@scripts/setHCP-ConsulEnv-use1.sh
	@echo Pausing for admin cluster consul initialisation
	@sleep 180

consul-usw2:
	@scripts/setHCP-ConsulEnv-usw2.sh
	@echo Pausing for user cluster consul initialisation
	@sleep 180

consul-clean:
	@-examples/apps-peer-dataplane-ap-def/peering/peer_east_to_west.sh del
	@-examples/apps-peer-server-def-def/peering/peer_east_to_west.sh del
	@-examples/apps-peer-dataplane-ap-def/fake-service/deploy-with-failover.sh del
	@-examples/apps-peer-server-def-def/fake-service/deploy-with-failover.sh del
	@-terraform -chdir="consul_helm_values" destroy -auto-approve 
	@terraform -chdir="quickstart/infra_examples/2hcp-2eks-2ec2" destroy -auto-approve 

plan: init
	@terraform validate
	@terraform plan

destroy: init consul-clean

fmt:
	@terraform fmt -recursive

clean:
	-rm -rf .terraform/
	-rm .terraform.lock.hcl
	-rm terraform.tfstate*