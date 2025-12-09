output "rhino_eks_cluster_security_group_id" {
  value       = aws_security_group.rhino_eks_cluster_security_group.id
  description = "Security group for EKS cluster (Used for managing Workload Traffic)"
}

output "rhino_eks_cluster_worker_nodes_security_group_id" {
  value       = aws_security_group.rhino_eks_cluster_worker_nodes_security_group.id
  description = "EKS created security group applied to ENI that is attached to EKS Control Plane master nodes, as well as any managed workloads."
}