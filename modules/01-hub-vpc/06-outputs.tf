output "vpc_id" {
  value = aws_vpc.hub.id
}

output "tgw_subnet_id" {
  value = aws_subnet.tgw[*].id
}

output "pub_subnet_id" {
  value = aws_subnet.pub[*].id
}