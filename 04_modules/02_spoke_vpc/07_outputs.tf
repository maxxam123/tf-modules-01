output "nat_id" {
  value = aws_nat_gateway.this.id
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "tgw_id" {
  value = aws_subnet.tgw[*].id
}

output "pub_id" {
  value = aws_subnet.pri[*].id
}

output "igw_id" {
  value = aws_internet_gateway.this.id
}