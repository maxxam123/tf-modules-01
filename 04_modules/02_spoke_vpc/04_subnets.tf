resource "aws_subnet" "pri" {
  count = length(var.pri_subnets)

  vpc_id = aws_vpc.this.id
  cidr_block = var.pri_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "spoke-${var.env}-pri-subnet-${format("%02d", count.index + 1)}"
    NetworkTier = "spoke-pri-subnet"
  }
}

resource "aws_subnet" "tgw" {
  count = length(var.tgw_subnets)

  vpc_id = aws_vpc.hub.id
  cidr_block = var.tgw_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name      = "spoke-${var.env}-tgw-subnet-${format("%02d", count.index + 1)}"
    NetworkTier = "spoke-tgw-subnet"
  }
}