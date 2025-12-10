#===============================================================================
# Data Sources
#===============================================================================

data "aws_eks_cluster" "eks_cluster" {
  name       = var.eks_cluster_name
  depends_on = [aws_eks_cluster.eks_cluster]
}

data "aws_eks_cluster_auth" "cluster" {
  name       = var.eks_cluster_name
  depends_on = [aws_eks_cluster.eks_cluster]
}

#===============================================================================
# EKS Cluster Auth
#===============================================================================

resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0afd10e3d"]
  url             = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_eks_access_entry" "github_actions_role_access_entry" {
  cluster_name  = data.aws_eks_cluster.eks_cluster.name
  principal_arn = var.github_actions_role_arn
  type          = "STANDARD"
  depends_on    = [var.github_actions_role_arn]
}

resource "aws_eks_access_policy_association" "github_actions_admin_policy" {
  cluster_name  = data.aws_eks_cluster.eks_cluster.name
  principal_arn = var.github_actions_role_arn

  access_scope {
    type = "cluster"
  }

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}