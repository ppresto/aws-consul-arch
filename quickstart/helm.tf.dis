data "template_file" "eks_clients" {
  for_each = { for k, v in local.usw2 : k => v if contains(keys(v), "eks") }

  template = file("${path.module}/templates/consul_helm_client.tmpl")
  vars = {
    cluster_name               = try(local.usw2[each.key].eks.cluster_name, local.name)
    datacenter                 = module.hcp_consul_usw2[local.hvn_list_usw2[0]].datacenter
    release_name               = "consul-${each.key}"
    consul_external_servers             = local.consul_retry_join[0]
    consul_version             = "1.14.4-ent"
    consul_helm_chart_version  = "1.0.2"
    consul_helm_chart_template = "values-client-agentless-mesh.yaml"
    consul_chart_name                 = "consul"
    consul_ca_file             = module.hcp_consul_usw2[local.hvn_list_usw2[0]].consul_ca_file
    consul_config_file             = module.hcp_consul_usw2[local.hvn_list_usw2[0]].consul_config_file
    consul_root_token_secret_id = module.hcp_consul_usw2[local.hvn_list_usw2[0]].consul_root_token_secret_id
    #partition                     = "${element(var.regions, count.index)}-shared"
    partition = "default"
  }
}

resource "local_file" "client-tf" {
  for_each = { for k, v in local.usw2 : k => v if contains(keys(v), "eks") }
  content  = data.template_file.eks_clients[each.key].rendered
  filename = "${path.module}/../consul-clients/auto-${local.usw2[each.key].eks.cluster_name}.tf"
}