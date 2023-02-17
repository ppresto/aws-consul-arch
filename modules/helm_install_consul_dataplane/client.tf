/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */


resource "kubernetes_namespace" "consul" {
  metadata {
    name = var.kubernetes_namespace
  }
}

resource "helm_release" "consul_client" {
  chart            = var.chart_name
  create_namespace = var.create_namespace
  name             = var.release_name
  namespace        = var.kubernetes_namespace
  repository       = var.chart_repository
  timeout          = 900
  version          = var.consul_helm_chart_version

  values     = [data.template_file.consul-client.rendered]
  depends_on = [kubernetes_namespace.consul]
}
data "template_file" "consul-client" {
  template = file("${path.module}/templates/${var.consul_helm_chart_template}")
  vars = {
    consul_version            = var.consul_version
    consul_helm_chart_version = var.consul_helm_chart_version
    server_replicas           = var.server_replicas
    cluster_name              = var.cluster_name
    datacenter                = var.datacenter
    partition                 = var.consul_partition
    aks_cluster               = data.aws_eks_cluster.cluster.endpoint
    consul_external_servers   = var.consul_external_servers
  }
}
resource "local_file" "consul-client" {
  content  = data.template_file.consul-client.rendered
  filename = "./yaml/auto-${var.release_name}-values.yaml"
}

resource "kubernetes_secret" "consul_license_client" {
  metadata {
    name      = "consul-ent-license"
    namespace = var.kubernetes_namespace
  }
  data = {
    "key" = var.consul_license
  }
}

# Get Consul Cluster CA Certificate

resource "kubernetes_secret" "consul-ca-cert" {
  metadata {
    name      = "consul-ca-cert"
    namespace = var.kubernetes_namespace
  }
  data = {"tls.crt" = var.consul_ca_file}
}

# Get Consul Cluster bootstrap token

resource "kubernetes_secret" "consul-bootstrap-token" {
  metadata {
    name      = "consul-bootstrap-acl-token"
    namespace = var.kubernetes_namespace
  }
  data = {"token" = var.consul_root_token_secret_id}
}