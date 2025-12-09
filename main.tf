terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.36.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }

  required_version = ">= 1.5.7"

  backend "s3" {
    bucket         = "terraform-versioned-state-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

module "iam" {
  source = "../../modules/iam"
}

module "network" {
  source = "../../modules/network"
  eks_cluster_name = var.eks_cluster_name
  region           = var.region
}

module "compute" {
  source = "../../modules/compute"
}