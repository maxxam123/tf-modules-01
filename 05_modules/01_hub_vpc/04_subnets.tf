resource "aws_subnet" "pub" {
  count = length(var.pub_subnets)

  vpc_id = aws_vpc.hub.id
  cidr_block = var.pub_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "hub-${var.env}-pub-subnet-${format("%02d", count.index + 1)}"
    NetworkTier = "hub-pub-subnet"
  }
}

resource "aws_subnet" "tgw" {
  count = length(var.tgw_subnets)

  vpc_id = aws_vpc.hub.id
  cidr_block = var.tgw_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name      = "hub-${var.env}-tgw-subnet-${format("%02d", count.index + 1)}"
    NetworkTier = "hub-tgw-subnet"
  }
}