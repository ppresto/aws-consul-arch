module "aws_team2_eks-config" {
  source              = "../modules/workspace-mgr"
  agent_pool_id       = ""
  organization        = var.organization
  workspacename       = "aws_${local.region_shortname}_${var.env}_team2-eks-config"
  workingdir          = "aws_team2_eks-config"
  tfversion           = "1.1.4"
  queue_all_runs      = false
  auto_apply          = true
  identifier          = "${var.repo_org}/hcp-consul"
  oauth_token_id      = var.oauth_token_id
  repo_branch         = "main"
  global_remote_state = false
  tag_names           = ["team2", "dataplane", "${var.aws_default_region}", "${var.env}"]
  project_id           = tfe_project.twilio.id
  variable_set_enabled = true
  variable_set         = tfe_variable_set.cloud_creds.id

  env_variables = {
    "CONFIRM_DESTROY" : 1
    "AWS_DEFAULT_REGION" : var.aws_default_region
    "HCP_CLIENT_ID" = var.HCP_CLIENT_ID
  }
  tf_variables = {
    "region"            = var.aws_default_region
    "organization"      = var.organization
    "service_template"   = "fake-service"
    "namespace"         = "consul"
    "env"               = var.env
    "helm_release_name" = "team2"
    "helm_template"     = "helm-config-dataplane.yaml"
  }
  env_variables_sec = {
    "HCP_CLIENT_SECRET" = var.HCP_CLIENT_SECRET
  }
  tf_variables_sec = {}
}