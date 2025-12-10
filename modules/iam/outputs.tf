output "github_actions_role_arn" {
  description = "Role ARN for the role a github actions workflow will assume"
  value       = aws_iam_role.github_actions_role.arn
}

output "rhino_eks_cluster_role_arn" {
  value = aws_iam_role.rhino_eks_cluster_role.arn
}

output "rhino_eks_node_group_role_arn" {
  value = aws_iam_role.rhino_eks_node_group_role.arn
}

output "aws_load_balancer_controller_role_arn" {
  value = aws_iam_role.aws_load_balancer_controller_role.arn
}

output "eks_services_secrets_sa_role_arns" {
  description = "Map of service account role ARNs for accessing secrets"
  value       = { for k, v in aws_iam_role.eks_services_secrets_sa_role : k => v.arn }
}

output "aws_ebs_csi_driver_role_arn" {
  value = aws_iam_role.eks_aws_ebs_csi_controller_sa_role.arn
}
