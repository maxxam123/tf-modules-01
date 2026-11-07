output "nat_id" {
  value = aws_nat_gateway.this.id
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "fw_id" {
  value = aws_subnet.firewall[*].id
}

output "tgw_id" {
  value = aws_subnet.tgw[*].id
}

output "igw_id" {
  value = aws_internet_gateway.this.id
}

# output "fw_id" {
#   value = { for key, subnet in aws_subnet.public : key => subnet.id }
# }