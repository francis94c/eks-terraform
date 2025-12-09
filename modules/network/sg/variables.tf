variable "environment" {
  type = string
  description = "Name of the environment"
}

variable "region" {
  type        = string
  description = "The region all resources should be deployed to"
}

variable "eks_cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}