module "eks" {
  source                  = "./eks"
  eks_cluster_name        = var.eks_cluster_name
  region                  = var.region
  vpc_cidr                = var.vpc_cidr
  github_actions_role_arn = var.github_actions_role_arn
}