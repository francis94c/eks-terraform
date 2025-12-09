#===============================================================================
# LOCALS
#===============================================================================
locals {
  region_clean = upper(replace(var.region, "-", ""))
}

#===============================================================================
# VPC
#===============================================================================
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name                     = "${var.eks_cluster_name}/VPC"
    Product                  = "Sample Product"
    "karpenter.sh/discovery" = var.eks_cluster_name
  }
}

#===============================================================================
# Subnets
#===============================================================================

resource "aws_subnet" "subnet_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.vpc_cidr_blocks.subnet_1
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}b"
  tags = {
    Name                     = "${var.eks_cluster_name}/SubnetPublic${local.region_clean}B"
    Product                  = "Sample Product"
    "kubernetes.io/role/elb" = "1"
    "karpenter.sh/discovery" = var.eks_cluster_name
  }

  depends_on = [aws_vpc.vpc]
}

resource "aws_subnet" "subnet_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.vpc_cidr_blocks.subnet_2
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}c"
  tags = {
    Name                     = "${var.eks_cluster_name}/SubnetPublic${local.region_clean}C"
    Product                  = "Sample Product"
    "kubernetes.io/role/elb" = "1"
    "karpenter.sh/discovery" = var.eks_cluster_name
  }

  depends_on = [aws_vpc.vpc]
}

resource "aws_subnet" "subnet_3" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.vpc_cidr_blocks.subnet_3
  map_public_ip_on_launch = false
  availability_zone       = "${var.region}a"
  tags = {
    Name                              = "${var.eks_cluster_name}/SubnetPrivate${local.region_clean}A"
    Product                           = "Sample Product"
    "kubernetes.io/role/internal-elb" = "1"
    "karpenter.sh/discovery"          = var.eks_cluster_name
  }

  depends_on = [aws_vpc.vpc]
}

resource "aws_subnet" "subnet_4" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.vpc_cidr_blocks.subnet_4
  map_public_ip_on_launch = false
  availability_zone       = "${var.region}c"
  tags = {
    Name                              = "${var.eks_cluster_name}/SubnetPrivate${local.region_clean}C"
    Product                           = "Sample Product"
    "kubernetes.io/role/internal-elb" = "1"
    "karpenter.sh/discovery"          = var.eks_cluster_name
  }

  depends_on = [aws_vpc.vpc]
}

resource "aws_subnet" "subnet_5" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.vpc_cidr_blocks.subnet_5
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"
  tags = {
    Name                     = "${var.eks_cluster_name}/SubnetPublic${local.region_clean}A"
    Product                  = "Sample Product"
    "kubernetes.io/role/elb" = "1"
    "karpenter.sh/discovery" = var.eks_cluster_name
  }

  depends_on = [aws_vpc.vpc]
}

resource "aws_subnet" "subnet_6" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.vpc_cidr_blocks.subnet_6
  map_public_ip_on_launch = false
  availability_zone       = "${var.region}b"
  tags = {
    Name                              = "${var.eks_cluster_name}/SubnetPrivate${local.region_clean}B"
    Product                           = "Sample Product"
    "kubernetes.io/role/internal-elb" = "1"
    "karpenter.sh/discovery"          = var.eks_cluster_name
  }

  depends_on = [aws_vpc.vpc]
}

#===============================================================================
# Elastic IPs
#===============================================================================

resource "aws_eip" "nat_gateway_elastic_ip_allocation" {
}

#===============================================================================
# Gateways
#===============================================================================
resource "aws_nat_gateway" "nat_gateway" {
  subnet_id     = aws_subnet.subnet_2.id
  allocation_id = aws_eip.nat_gateway_elastic_ip_allocation.id
  tags = {
    Name = "${var.eks_cluster_name}/NATGateway"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name                     = "${var.eks_cluster_name}/InternetGateway"
    "karpenter.sh/discovery" = var.eks_cluster_name
  }
}

#===============================================================================
# Route Tables
#===============================================================================

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${var.eks_cluster_name}/PrivateRouteTable"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${var.eks_cluster_name}/PublicRouteTable"
  }
}

#===============================================================================
# Route Table Associations
#===============================================================================

resource "aws_route_table_association" "private_route_table_association_1" {
  subnet_id      = aws_subnet.subnet_3.id
  route_table_id = aws_route_table.private_route_table.id

  depends_on = [aws_subnet.subnet_3, aws_route_table.private_route_table, aws_nat_gateway.nat_gateway]
}

resource "aws_route_table_association" "private_route_table_association_2" {
  subnet_id      = aws_subnet.subnet_4.id
  route_table_id = aws_route_table.private_route_table.id

  depends_on = [aws_subnet.subnet_4, aws_route_table.private_route_table, aws_nat_gateway.nat_gateway]
}

resource "aws_route_table_association" "private_route_table_association_3" {
  subnet_id      = aws_subnet.subnet_6.id
  route_table_id = aws_route_table.private_route_table.id

  depends_on = [aws_subnet.subnet_6, aws_route_table.private_route_table, aws_nat_gateway.nat_gateway]
}

resource "aws_route_table_association" "public_route_table_association_1" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.public_route_table.id

  depends_on = [aws_subnet.subnet_1, aws_route_table.public_route_table, aws_internet_gateway.internet_gateway]
}

resource "aws_route_table_association" "public_route_table_association_2" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.public_route_table.id

  depends_on = [aws_subnet.subnet_2, aws_route_table.public_route_table, aws_internet_gateway.internet_gateway]
}

resource "aws_route_table_association" "public_route_table_association_3" {
  subnet_id      = aws_subnet.subnet_5.id
  route_table_id = aws_route_table.public_route_table.id

  depends_on = [aws_subnet.subnet_5, aws_route_table.public_route_table, aws_internet_gateway.internet_gateway]
}
