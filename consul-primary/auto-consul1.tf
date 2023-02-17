#provider "azurerm" {
#  features {}
#}

module "consul_consul1" {
  source                        = "../modules/helm_install"
  release_name                  = "consul1-westus2"
  chart_name                    = "consul"
  azure_key_vault_id            = "/subscriptions/14692f20-9428-451b-8298-102ed4e39c2a/resourceGroups/dmed-eastus-mr/providers/Microsoft.KeyVault/vaults/dmed-aks-cdb9dc2d"
  azure_key_vault_name          = "dmed-aks-cdb9dc2d"
  key_vault_resource_group_name = "dmed-eastus-mr"
  resource_group_name           = "dmed-westus2-mr"
  datacenter                    = "consul1-westus2"
  consul_partition              = "default"
  cluster_name                  = "consul1"
  server_replicas               = 3
  consul_version                = "1.14.3-ent"
  consul_license                = file("../files/consul.lic")
  enable_cluster_peering        = true
  consul_helm_chart_version     = "1.0.2"

  # If WAN Federation is enabled, verify primary/secondary and configure accordingly
  primary_datacenter         = true
  consul_helm_chart_template = "values-peer-mesh.yaml"

}

