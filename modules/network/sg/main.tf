#===============================================================================
# Security Groups
#===============================================================================

resource "aws_security_group" "eks_cluster_security_group" {
  name        = "${var.eks_cluster_name}-ControlPlaneSecurityGroup"
  vpc_id      = var.vpc_id
  description = "Communication between the control plane and worker node groups"

  ingress {
    description = "Allow kubectl/API access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/16"]
  }

  tags = {
    Name    = "${var.eks_cluster_name}-ControlPlaneSecurityGroup"
    Product = "Sample Product"
  }
}

resource "aws_security_group" "eks_cluster_worker_nodes_security_group" {
  name        = "${var.eks_cluster_name}-WorkerNodesSecurityGroup"
  vpc_id      = var.vpc_id
  description = "EKS created security group applied to ENI that is attached to EKS Control Plane master nodes, as well as any managed workloads."

  # Allow nodes to communicate with each other
  ingress {
    description = "Allow inter-node communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # Allow worker nodes to receive API traffic from the cluster control plane
  ingress {
    description     = "Allow control plane to reach nodes"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster_security_group.id]
  }

  ingress {
    description     = "Allow access to back end service"
    from_port       = 30080
    to_port         = 30080
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster_security_group.id]
  }

  ingress {
    description     = "Allow control plane to reach nodes"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster_security_group.id]
  }

  # Allow nodes to reach the internet and EKS control plane
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                            = "${var.eks_cluster_name}-WorkerNodesSecurityGroup"
    Product                                         = "Sample Product"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
    "karpenter.sh/discovery"                        = var.eks_cluster_name
  }
}