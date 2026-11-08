resource "aws_eip" "eip" {
  domain = "vpc"

  tags = {
    Name = "hub-${var.env}-eip"
    NetworkTier = "hub-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id = var.pub_subnets[0].id

  tags = {
    Name = "hub-${var.env}-nat"
    NetworkTier = "hub-nat"
  }

  depends_on = [ aws_internet_gateway.igw ]
}