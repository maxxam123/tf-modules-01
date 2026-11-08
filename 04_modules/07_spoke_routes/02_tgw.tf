data "aws_ec2_transit_gateway" "hub_tgw" {
  filter {
    name   = "tag:NetworkTier"
    values = ["hub-tgw"]
  }
}

data "aws_vpc" "spoke_vpc" {
  filter {
    name   = "tag:NetworkTier"
    values = ["spoke-vpc"]
  }
}

data "aws_subnets" "spoke_tgw_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.spoke_vpc.id]
  }

  filter {
    name   = "tag:NetworkTier"
    values = ["spoke-tgw-subnet"]
  }
}

resource "aws_route_table" "spoke_tgw_rt" {
  vpc_id = data.aws_vpc.hub_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = data.aws_ec2_transit_gateway.hub_tgw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = toset(data.aws_subnets.spoke_tgw_subnets.ids)
  
  subnet_id      = each.value
  route_table_id = aws_route_table.spoke_tgw_rt[each.value].id
}

