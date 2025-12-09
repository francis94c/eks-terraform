output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_ids" {
  value = [
    aws_subnet.subnet_1.id,
    aws_subnet.subnet_2.id,
    aws_subnet.subnet_3.id,
    aws_subnet.subnet_4.id,
    aws_subnet.subnet_5.id,
    aws_subnet.subnet_6.id,
  ]
}

output "private_subnet_ids" {
  value = [
    aws_subnet.subnet_3.id,
    aws_subnet.subnet_4.id,
    aws_subnet.subnet_6.id,
  ]
}

output "public_subnet_ids" {
  value = [
    aws_subnet.subnet_1.id,
    aws_subnet.subnet_2.id,
    aws_subnet.subnet_5.id,
  ]
}
