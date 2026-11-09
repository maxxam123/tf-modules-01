data "aws_internet_gateway" "hub_igw" {
  filter {
    name   = "tag:NetworkTier"
    values = ["hub-igw"]
  }
}

data "aws_ec2_transit_gateway" "hub_tgw" {
  filter {
    name   = "tag:NetworkTier"
    values = ["hub-tgw"]
  }
}

data "aws_vpc" "hub_vpc" {
  filter {
    name   = "tag:NetworkTier"
    values = ["hub-vpc"]
  }
}

data "aws_subnets" "public_subnets_details" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.hub_vpc.id]
  }

  filter {
    name   = "tag:NetworkTier"
    values = ["hub-pub-subnet"]
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = data.aws_vpc.hub_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.hub_igw.id
  }

  route {
    cidr_block = "20.0.0.0/16"
    transit_gateway_id = data.aws_ec2_transit_gateway.hub_tgw.id
  }

  tags = {
    Name = "${var.env}-public"
  }
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = toset(data.aws_subnets.public_subnets_details.ids)
  
  subnet_id      = each.value
  route_table_id = aws_route_table.public_rt[each.value].id
}

