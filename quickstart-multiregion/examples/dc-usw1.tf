provider "aws" {
  alias  = "usw1"
  region = "us-west-1"
}

data "aws_availability_zones" "usw1" {
  provider = aws.usw1
  state    = "available"
}

data "aws_caller_identity" "usw1" {
  provider = aws.usw1
}

locals {
  tgw_list_usw1 = flatten([for env, values in local.usw1 :
    [
      "${env}"
    ] if contains(keys(values), "tgw")
  ])
  vpc_tgw_locations_usw1 = flatten([for env, values in local.usw1 :
    flatten([for tgw-key, tgw-val in local.tgw_list_usw1 :
      {
        "${env}-tgw-${tgw-val}" = {
          "tgw_env" = tgw-val
          "vpc_env" = env
        }
      }
    ])
  ])
  vpc_tgw_cidr_routes_usw1 = flatten([for env, values in local.usw1 :
    flatten([for tgw-key, tgw-val in local.tgw_list_usw1 :
      flatten([for cidr in values.vpc.private_cidr_blocks :
        {
          "${env}-${cidr}" = {
            "tgw_env" = tgw-val
            "vpc_env" = env
            "cidr"    = cidr
          }
        }
      ])
    ])
  ])
  # transform the list into a map
  vpc_tgw_cidr_routes_map_usw1 = { for item in local.vpc_tgw_cidr_routes_usw1 :
    keys(item)[0] => values(item)[0]
  }
  vpc_tgw_locations_map_usw1 = { for item in local.vpc_tgw_locations_usw1 :
    keys(item)[0] => values(item)[0]
  }

  # us-west-1 datacenter configuration
  usw1 = {
    "usw1-shared" = {
      "name" : "usw1-shared",
      "region" : "us-west-1",
      "vpc" = {
        "name" : "${var.prefix}-usw1-shared"
        "cidr" : "10.15.0.0/16",
        "private_subnets" : ["10.15.1.0/24", "10.15.2.0/24"],
        "public_subnets" : ["10.15.11.0/24", "10.15.12.0/24"],
        "private_cidr_blocks" : ["10.0.0.0/10"],
      }
      "tgw" = { #Only 1 TGW needed per region/data center.  Other VPC's can attach to it.
        "name" : "${var.prefix}-usw1-tgw",
        "enable_auto_accept_shared_attachments" : true,
        "ram_allow_external_principals" : true
      }
      "eks" = {
        "cluster_name" : "${var.prefix}-usw1-shared",
        "cluster_version" : var.eks_cluster_version,
        "ec2_ssh_key" : var.ec2_key_pair_name,
        "cluster_endpoint_private_access" : true,
        "cluster_endpoint_public_access" : true
      }
      # No HCP Support in us-west-1 
      # "hcp-consul" = {
      #   "hvn_id"         = var.hvn_id
      #   "cloud_provider" = var.cloud_provider
      #   "region"         = data.aws_region.current.name
      #   "cidr_block"     = var.hvn_cidr_block
      #   "cluster_id"         = var.cluster_id
      #   "tier"               = "development"
      #   "min_consul_version" = var.min_consul_version
      #   "public_endpoint"    = true
      # }
    },
    "usw1-app1" = {
      "name" : "usw1-app1",
      "region" : "us-west-1",
      "vpc" = {
        "name" : "${var.prefix}-usw1-app1"
        "cidr" : "10.16.0.0/16",
        "private_subnets" : ["10.16.1.0/24", "10.16.2.0/24"],
        "public_subnets" : ["10.16.11.0/24", "10.16.12.0/24"],
        "private_cidr_blocks" : ["10.0.0.0/10"]
      }
      "eks" = {
        "cluster_name" : "${var.prefix}-usw1-app1",
        "ec2_ssh_key" : var.ec2_key_pair_name
      }
    }
  }
}

# VPC: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
module "vpc-usw1" {
  providers = {
    aws = aws.usw1
  }
  source                   = "terraform-aws-modules/vpc/aws"
  version                  = "~> 3.0"
  for_each                 = local.usw1
  name                     = try(local.usw1[each.key].vpc.name, "${var.prefix}-${local.region_shortname}-vpc")
  cidr                     = local.usw1[each.key].vpc.cidr
  azs                      = data.aws_availability_zones.usw1.names
  private_subnets          = local.usw1[each.key].vpc.private_subnets
  public_subnets           = local.usw1[each.key].vpc.public_subnets
  enable_nat_gateway       = true
  single_nat_gateway       = true
  enable_dns_hostnames     = true
  enable_ipv6              = false
  default_route_table_name = "${var.prefix}-${each.key}-vpc1"
  tags = {
    Terraform  = "true"
    Owner      = "${var.prefix}"
    transit_gw = "true"
  }
  private_subnet_tags = {
    Tier = "Private"
  }
  public_subnet_tags = {
    Tier = "Public"
  }
  default_route_table_tags = {
    Name = "${var.prefix}-vpc1-default"
  }
  private_route_table_tags = {
    Name = "${var.prefix}-vpc1-private"
  }
  public_route_table_tags = {
    Name = "${var.prefix}-vpc1-public"
  }
}

# TransitGateway: https://registry.terraform.io/modules/terraform-aws-modules/transit-gateway/aws/latest
module "tgw-usw1" {
  providers = {
    aws = aws.usw1
  }
  #provider = data.aws_region.primary
  source = "terraform-aws-modules/transit-gateway/aws"
  #version = "2.5.0"
  version = "2.8.2"

  for_each                              = { for k, v in local.usw1 : k => v if contains(keys(v), "tgw") }
  description                           = "${local.region_shortname} - Centrally shared Transit Gateway"
  name                                  = try(local.usw1[each.key].tgw.name, "${var.prefix}-${local.region_shortname}-vpc1-tgw")
  enable_auto_accept_shared_attachments = try(local.usw1[each.key].tgw.enable_auto_accept_shared_attachments, true) # When "true" there is no need for RAM resources if using multiple AWS accounts
  ram_allow_external_principals         = try(local.usw1[each.key].tgw.ram_allow_external_principals, true)
  amazon_side_asn                       = 64532
  tgw_default_route_table_tags = {
    name = "${local.region_shortname}-tgw-default_rt"
  }
  tags = {
    project = "${local.region_shortname}-vpc1-tgw"
  }
}

# resource "aws_ec2_transit_gateway_peering_attachment" "example" {
#   peer_account_id         = data.aws_caller_identity.primary.account_id
#   peer_region             = data.aws_region.primary.name
#   peer_transit_gateway_id = module.tgw.ec2_transit_gateway_id
#   transit_gateway_id      = module.tgw-secondary.ec2_transit_gateway_id

#   tags = {
#     Name = "TGW Peering Requestor"
#   }
# }

# EKS: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
module "eks-usw1" {
  providers = {
    aws = aws.usw1
  }
  source  = "terraform-aws-modules/eks/aws"
  version = "19.5.1"

  for_each                              = { for k, v in local.usw1 : k => v if contains(keys(v), "eks") }
  cluster_name                          = try(local.usw1[each.key].eks.cluster_name, local.name)
  cluster_version                       = try(local.usw1[each.key].eks.eks_cluster_version, var.eks_cluster_version)
  cluster_endpoint_private_access       = try(local.usw1[each.key].eks.cluster_endpoint_private_access, true)
  cluster_endpoint_public_access        = try(local.usw1[each.key].eks.cluster_endpoint_public_access, true)
  cluster_additional_security_group_ids = [module.sg-usw1[each.key].consul_server_securitygroup_id]
  vpc_id                                = module.vpc-usw1[each.key].vpc_id
  subnet_ids                            = module.vpc-usw1[each.key].private_subnets
  cluster_addons = {
    #coredns = {
    #  resolve_conflicts = "OVERWRITE"
    #}
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }
  create_kms_key = true
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    disk_size      = 50
    instance_types = ["t3.medium"]
  }
  eks_managed_node_groups = {
    # Default node group - as provided by AWS EKS
    default_node_group = {
      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      use_custom_launch_template = false
      #launch_template_name   = "default"

      # Remote access cannot be specified with a launch template
      remote_access = {
        ec2_ssh_key               = var.ec2_key_pair_name
        source_security_group_ids = [module.sg-usw1[each.key].consul_server_securitygroup_id]
      }
    }
  }
}

module "sg-usw1" {
  providers = {
    aws = aws.usw1
  }
  source                = "../modules/aws_consul_sg"
  for_each              = local.usw1
  region                = local.usw1[each.key].region
  security_group_create = true
  name_prefix           = "${local.usw1[each.key].name}-consul-sg"
  # securit_group_id = ...
  vpc_id         = module.vpc-usw1[each.key].vpc_id
  vpc_cidr_block = local.usw1[each.key].vpc.cidr
}

#
### Setup Transit Gateway attachments and private routes for the environment
#
module "tgw_vpc_attach_usw1" {
  source = "../modules/aws_tgw_vpc_attach"
  providers = {
    aws = aws.usw1
  }
  for_each           = local.vpc_tgw_locations_map_usw1
  subnet_ids         = module.vpc-usw1[each.value.vpc_env].private_subnets
  transit_gateway_id = module.tgw-usw1[each.value.tgw_env].ec2_transit_gateway_id
  vpc_id             = module.vpc-usw1[each.value.vpc_env].vpc_id
  tags = {
    project = "${local.region_shortname}-vpc-usw1-tgw"
  }
}

module "route_add_usw1" {
  source = "../modules/aws_route_add"
  providers = {
    aws = aws.usw1
  }
  for_each               = local.vpc_tgw_cidr_routes_map_usw1
  route_table_id         = module.vpc-usw1[each.value.vpc_env].private_route_table_ids[0]
  destination_cidr_block = each.value.cidr
  transit_gateway_id     = module.tgw-usw1[each.value.tgw_env].ec2_transit_gateway_id
}

# resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-usw1" {
#   for_each = local.vpc_tgw_locations_map_usw1
#   subnet_ids         = module.vpc-usw1[each.value.vpc_env].private_subnets
#   transit_gateway_id = module.tgw-usw1[each.value.tgw_env].ec2_transit_gateway_id
#   vpc_id             = module.vpc-usw1[each.value.vpc_env].vpc_id
#   tags = {
#     project = "${local.region_shortname}-vpc-usw1-tgw"
#   }
# }

# resource "aws_route" "privateToAllInt-usw1" {
#   for_each               = local.vpc_tgw_cidr_routes_map_usw1
#   route_table_id         = module.vpc-usw1[each.value.vpc_env].private_route_table_ids[0]
#   destination_cidr_block = each.value.cidr
#   transit_gateway_id     = module.tgw-usw1[each.value.tgw_env].ec2_transit_gateway_id
# }

# VPC
output "usw1_vpc_ids" {
  value = { for env in sort(keys(local.usw1)) :
    env => module.vpc-usw1[env].vpc_id
  }
}

### EKS
output "usw1_eks_cluster_endpoints" {
  description = "Endpoint for your Kubernetes API server"
  value       = { for k, v in local.usw1 : k => module.eks-usw1[k].cluster_endpoint if contains(keys(v), "eks") }
}
output "usw1_eks_cluster_names" {
  description = "The name/id of the EKS cluster. Will block on cluster creation until the cluster is really ready"
  value       = { for k, v in local.usw1 : k => module.eks-usw1[k].cluster_name if contains(keys(v), "eks") }
}

### Transit Gateway
output "usw1_ec2_transit_gateway_arn" {
  description = "EC2 Transit Gateway Amazon Resource Name (ARN)"
  value       = { for k, v in local.usw1 : k => module.tgw-usw1[k].ec2_transit_gateway_arn if contains(keys(v), "tgw") }
}

output "usw1_ec2_transit_gateway_id" {
  description = "EC2 Transit Gateway identifier"
  value       = { for k, v in local.usw1 : k => module.tgw-usw1[k].ec2_transit_gateway_id if contains(keys(v), "tgw") }
}
