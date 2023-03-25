terraform {
  required_version = ">= 1.3.7"

  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.53.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.17.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.51.0"
    }
  }
}

provider "consul" {
  address    = "https://presto-cluster-usw2.consul.328306de-41b8-43a7-9c38-ca8d89d06b07.aws.hashicorp.cloud:443"
  datacenter = "presto-cluster-usw2"
  token  = "80516bf8-1a72-71b0-ccb4-5fa008deaf97"
}