resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id = aws_vpc.this.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.env}-public-subnet"
    "network" = "public"
  }
}

resource "aws_subnet" "firewall" {
  count = length(var.firewall_subnets)

  vpc_id = aws_vpc.this.id
  cidr_block = var.firewall_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name      = "${var.env}-fw-subnet"
    "network" = "fw"
  }
}

resource "aws_subnet" "tgw" {
  count = length(var.tgw_subnet)

  vpc_id = aws_vpc.this.id
  cidr_block = var.tgw_subnet[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.env}-tgw-subnet"
    "network" = "tgw"
  }
}