
# variable data structure
```
locals {
  iam_teams = {
    "team1" = {
      "name" : "team1",
      "env" : "dev",
      "gsa" : "${var.organization}-gsa-tfc-team1",
      "roles" : ["compute.admin","storage.objectAdmin"],
      "namespace" : "tfc-team1",
      "k8s_sa" : "tfc-team1-dev",
    },
    "team2" = {
      "name" : "team2",
      "env" : "dev",
      "gsa" : "${var.organization}-gsa-tfc-team2",
      "roles" : ["storage.objectAdmin"],
      "namespace" : "tfc-team2",
      "k8s_sa" : "tfc-team2-dev",
    }
  }
  iam_team_workspaces = {
    "team1" = {
      "organization" : var.organization
      "workspacename" : "gke_team_team1"
      "workingdir" : "tfc-agent-gke/gke_tfc_team1"
      "tfversion" : "0.13.6"
      "queue_all_runs" : false
      "auto_apply" : true
      "agent_pool_id"     : module.iam-team-setup["team1"].agentpool_id
      "identifier" : "${var.repo_org}/tfc-agent"
      "oauth_token_id" : var.oauth_token_id
      "repobranch" : var.repo_branch
      "env_variables" : {
        "CONFIRM_DESTROY" : 1
        "GOOGLE_REGION"      : var.gcp_region
        "GOOGLE_PROJECT"     : var.gcp_project
        "GOOGLE_ZONE"        : var.gcp_zone
      }
      "env_variables_sec" : {}
      "tf_variables" : {
        "prefix" : var.organization
        "gcp_project" : var.gcp_project
        "gcp_region" : "us-west1"
        "gcp_zone" : "us-west1-c"
      }
      "tf_variables_sec" : {}
    }
    "team2" = {
      "organization" : var.organization
      "workspacename" : "gke_team_team2"
      "workingdir" : "tfc-agent-gke/gke_tfc_team2"
      "tfversion" : "1.0.5"
      "queue_all_runs" : false
      "auto_apply" : true
      "agent_pool_id"     : module.iam-team-setup["team2"].agentpool_id
      "identifier" : "${var.repo_org}/tfc-agent"
      "oauth_token_id" : var.oauth_token_id
      "repobranch" : var.repo_branch
      "env_variables" : {
        "CONFIRM_DESTROY" : 1
        "GOOGLE_REGION"      : var.gcp_region
        "GOOGLE_PROJECT"     : var.gcp_project
        "GOOGLE_ZONE"        : var.gcp_zone
      }
      "env_variables_sec" : {}
      "tf_variables" : {
        "prefix" : var.organization
        "gcp_project" : var.gcp_project
        "gcp_region" : "us-west1"
        "gcp_zone" : "us-west1-c"
      }
      "tf_variables_sec" : {}
    }
  }
}
```
## Create iam-teams
```
module "iam-team-setup" {
  source         = "../modules/iam-team-setup"
  for_each      = local.iam_teams
  team          = local.iam_teams[each.key]
  prefix        = "${var.prefix}-${each.key}"
  organization  = var.organization
  tfe_token     = var.tfe_token
  gcp_project = var.gcp_project
  gcp_region  = var.gcp_region
  gcp_zone    = var.gcp_zone
}
```
## creating all team workspaces
```
module "iam_team_workspaces" {
    source = "../modules/workspace-mgr"
    for_each = local.iam_team_workspaces

    agent_pool_id     = module.iam-team-setup[each.key].agentpool_id

    organization = local.iam_team_workspaces[each.key].organization
    workspacename = local.iam_team_workspaces[each.key].workspacename
    workingdir = local.iam_team_workspaces[each.key].workingdir
    tfversion = local.iam_team_workspaces[each.key].tfversion
    queue_all_runs = local.iam_team_workspaces[each.key].queue_all_runs
    auto_apply = local.iam_team_workspaces[each.key].auto_apply

    identifier     = local.iam_team_workspaces[each.key].identifier
    oauth_token_id = local.iam_team_workspaces[each.key].oauth_token_id
    repo_branch         = local.iam_team_workspaces[each.key].repobranch

    env_variables      = local.iam_team_workspaces[each.key].env_variables
    env_variables_sec  = local.iam_team_workspaces[each.key].env_variables_sec
    tf_variables = local.iam_team_workspaces[each.key].tf_variables
    tf_variables_sec = local.iam_team_workspaces[each.key].tf_variables_sec
}
```
## outputs
```
output "team_service_account_email" {
    value = { for t in sort(keys(local.iam_teams)) :
        t => {"gsa":module.iam-team-setup[t].team_gsa}
    }
}

output "agentpool_id" {
    value = { for t in sort(keys(local.iam_teams)) :
        t => {"agentpool":module.iam-team-setup[t].agentpool_id}
    }
}

output "team_iam_config" {
    value = {
        for team, configs in local.iam_teams: team => merge(
            configs, {"pool":module.iam-team-setup[team].agentpool_id}
        )
    }
}
```