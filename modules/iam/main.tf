#===============================================================================
# Data Sources
#===============================================================================
data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}

data "aws_caller_identity" "current" {}
