data "hcp_consul_versions" "default" {}

resource "hcp_hvn" "example_hvn" {
  hvn_id         = var.hvn_id
  cloud_provider = var.cloud_provider
  region         = var.region
  cidr_block     = var.cidr_block
}
resource "hcp_consul_cluster" "example_hcp" {
  hvn_id             = hcp_hvn.example_hvn.hvn_id
  cluster_id         = var.cluster_id
  tier               = var.tier
  min_consul_version = var.min_consul_version
  public_endpoint    = var.public_endpoint
}