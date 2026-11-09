output "nat_id" {
  value = aws_nat_gateway.nat.id
}

output "vpc_id" {
  value = aws_vpc.hub.id
}

output "tgw_id" {
  value = aws_subnet.tgw[*].id
}

output "pub_id" {
  value = aws_subnet.pub[*].id
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}
