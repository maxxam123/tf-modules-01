resource "aws_eip" "this" {
  domain = "vpc"

  tags = {
    Name = "${var.env}-main"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.id
  subnet_id = var.public_subnets[0].id

  tags = {
    Name = "${var.env}-main"
    "nat" = "nat"
  }

  depends_on = [ aws_internet_gateway.this ]
}