output "vpc_id" {
  value = aws_vpc.this.id
}

output "tgw_subnet_id" {
  value = aws_subnet.tgw[*].id
}

output "alb_subnet_id" {
  value = aws_subnet.pri[*].id
}