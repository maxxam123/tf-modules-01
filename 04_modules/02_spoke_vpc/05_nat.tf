resource "aws_eip" "this" {
  domain = "vpc"

  tags = {
    Name = "spoke-${var.env}-eip-${format("%02d", count.index + 1)}"
    NetworkTier = "spoke-iep"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.id
  subnet_id = var.pri_subnets[0].id

  tags = {
    Name = "spoke-${var.env}-nat-${format("%02d", count.index + 1)}"
    NetworkTier = "spoke-nat"
  }

  depends_on = [ aws_internet_gateway.this ]
}