ec2_key_pair_name          = "ppresto-ptfe-dev-key"
eks_cluster_version        = "1.24"
consul_version             = "1.14.4-ent"
consul_helm_chart_version  = "1.0.2"
consul_helm_chart_template = "values-dataplane-hcp.yaml"
#consul_helm_chart_template = "values-server.yaml"
#consul_helm_chart_template = "values-dataplane.yaml"

consul_partition            = "default"