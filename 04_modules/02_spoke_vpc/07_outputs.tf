output "vpc_id" {
  value = aws_vpc.this.id
}

output "tgw_id" {
  value = aws_subnet.tgw[*].id
}

output "pri_id" {
  value = aws_subnet.pri[*].id
}
