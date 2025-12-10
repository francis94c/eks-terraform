variable "region" {
  type        = string
  description = "The region all resources should be deployed to"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
}

variable "eks_cluster_name" {
  type = string
}

variable "github_actions_role_arn" {
  type = string
}