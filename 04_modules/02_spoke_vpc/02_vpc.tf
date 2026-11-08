resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block

  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "spoke-${var.env}-vpc-${format("%02d", count.index + 1)}"
    NetworkTier = "spoke-vpc"
  }
}