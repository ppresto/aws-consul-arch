.PHONY: all init deploy plan destroy fmt clean
.PHONY: consul consul-info consul-use1 consul-usw2 awslb dataplane fake-service

OUTPUT=`terraform output -raw`

all: deploy consul

init: fmt
	@terraform init

deploy: init
	@terraform apply -auto-approve
	@echo "Source the following script to connect to all EKS clusters"
	@echo
	@echo "source ../../../scripts/kubectl_connect_eks.sh ."

consul: awslb dataplane consul-info fake-service

awslb:
	@../../../scripts/install_awslb_controller.sh .

dataplane:
	@terraform -chdir="../../../consul_helm_values" init
	@terraform -chdir="../../../consul_helm_values" apply -auto-approve

consul-info:
	@echo "Login to Consul UI - West"
	@source "../../../scripts/setHCP-ConsulEnv-usw2.sh" .
	@echo

fake-service:
	@ "../../../examples/apps-peer-dataplane-ap-def/peering/peer_east_to_west.sh"
	@ "../../../examples/apps-peer-dataplane-ap-def/fake-service/deploy-with-failover.sh"
consul-use1:
	@source "../../../scripts/setHCP-ConsulEnv-use1.sh" .

consul-usw2:
	@source "../../../scripts/setHCP-ConsulEnv-usw2.sh" .

consul-clean:
	@-../../../examples/apps-peer-dataplane-ap-def/peering/peer_east_to_west.sh del
	@-../../../examples/apps-peer-server-def-def/peering/peer_east_to_west.sh del
	@-../../../examples/apps-peer-dataplane-ap-def/fake-service/deploy-with-failover.sh del
	@-../../../examples/apps-peer-server-def-def/fake-service/deploy-with-failover.sh del
	@-terraform -chdir="../../../consul_helm_values" destroy -auto-approve 
	@- helm uninstall -n kube-system aws-load-balancer-controller eks/aws-load-balancer-controller
	@terraform destroy -auto-approve 

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