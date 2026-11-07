output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnet_private_id" {
  value = subnet_private[*].id
}

output "subnet_public_id" {
  value = subnet_public[*].id
}