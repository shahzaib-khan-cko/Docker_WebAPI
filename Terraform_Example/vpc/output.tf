output "public_subnet_a_id" {
  value = aws_subnet.public_a.id
}

output "public_subnet_b_id" {
  value = aws_subnet.public_b.id
}

output "public_subnet_a" {
  value = aws_subnet.public_a
}

output "public_subnet_b" {
  value = aws_subnet.public_b
}

output "vpc_id" {
  value = aws_vpc.aws-vpc.id
}

output "private_subnet_a_id" {
  value = aws_subnet.private_a.id
}

output "private_subnet_b_id" {
  value = aws_subnet.public_b.id
}

output "private_subnet_a" {
  value = aws_subnet.private_a
}


output "private_subnet_b" {
  value = aws_subnet.private_b
}

output "alb_target_group_arn" {
  value = aws_alb_target_group.alb-target-group.arn
}