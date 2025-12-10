#===============================================================================
# Locals
#===============================================================================

locals {
  github_repo_subs = [
    for repo in var.github_repos : "repo:${repo}:*"
  ]
}

#===============================================================================
# OIDC Provider for GitHub
#===============================================================================

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

#===============================================================================
# IAM Role for GitHub Actions
#===============================================================================

resource "aws_iam_role" "github_actions_role" {
  name = "GitHub_Actions_WIF_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = local.github_repo_subs
          }
        }
      }
    ]
  })
}

#===============================================================================
# Policies
#===============================================================================

resource "aws_iam_policy" "describe_vpcs_policy" {
  name        = "DescribeVpcsPolicy"
  description = "Allow describing VPCs and tags"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "s3_buckets_policy" {
  name        = "S3BucketsPolicy"
  description = "Allow access to S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = "*"
      }
    ]
  })
}

#===============================================================================
# Policy Attachments
#===============================================================================

resource "aws_iam_role_policy_attachment" "core_policy_attachments" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  ])
  role       = aws_iam_role.github_actions_role.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "describe_vpcs_policy_attachment" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.describe_vpcs_policy.arn
}

resource "aws_iam_role_policy_attachment" "s3_buckets_policy_attachment" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.s3_buckets_policy.arn
}
