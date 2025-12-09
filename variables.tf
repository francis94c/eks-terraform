variable "region" {
  type        = string
  description = "The region all resources should be deployed to"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR"
}

variable "vpc_cidr_blocks" {
  type        = map(any)
  description = "VPC CIDR blocks"
  default = {
    subnet_1 = "10.0.0.0/19"
    subnet_2 = "10.0.32.0/19"
    subnet_3 = "10.0.64.0/19"
    subnet_4 = "10.0.96.0/19"
    subnet_5 = "10.0.128.0/19"
    subnet_6 = "10.0.160.0/19"
  }
}

variable "eks_cluster_name" {
  type    = string
  default = "eks-cluster"
}