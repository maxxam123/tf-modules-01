data "aws_vpc" "hub_vpc" {
  filter {
    name   = "tag:NetworkTier"
    values = ["hub-vpc"]
  }
}

data "aws_subnets" "tgw_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.hub_vpc.id]
  }

  filter {
    name   = "tag:NetworkTier"
    values = ["hub-tgw-subnet"]
  }
}

data "aws_nat_gateway" "hub_nat" {
  filter {
    name   = "tag:NetworkTier"
    values = ["hub-nat"]
  }
}

resource "aws_route_table" "tgw_rt" {
  vpc_id = data.aws_vpc.hub_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = data.aws_nat_gateway.hub_nat.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = toset(data.aws_subnets.tgw_subnets.ids)
  
  subnet_id      = each.value
  route_table_id = aws_route_table.tgw_rt[each.value].id
}

