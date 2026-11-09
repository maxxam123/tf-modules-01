data "aws_internet_gateway" "hub_igw" {
  filter {
    name   = "tag:igw"
    values = ["igw"]
  }
}

data "aws_ec2_transit_gateway" "tgw" {
  filter {
    name   = "tag:tgw"
    values = ["tgw"]
  }
}

# data "aws_nat_gateway" "nat_gw" {
#  filter {
#    name = "tag:nat"
#    values = ["nat"]
#  }
# } 

data "aws_nat_gateways" "nat_gw" {
  vpc_id = data.aws_vpc.hub_vpc.id
  filter {
    name   = "tag:nat"
    values = ["nat"]
  }
}

data "aws_vpc" "hub_vpc" {
  filter {
    name   = "tag:Name"
    values = ["dev-vpc"] # 🔍 Searches all VPCs in your AWS account for this exact Name tag
  }
}

data "aws_subnets" "fw_subnets_details" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.hub_vpc.id] # 1. Only look inside the VPC we just found above
  }

  filter {
    name   = "tag:network"
    values = ["fw"] # 2. Only grab subnets that have this custom tier tag
  }
}

locals {
  # Maps "us-east-1a" => "nat-0123456789abcdef0"
  az_to_nat_gw_id = {
    for gw in data.aws_nat_gateway.individual_nat_gw : gw.availability_zone => gw.id
  }
}

resource "aws_route_table" "fw_rt" {
  vpc_id = data.aws_vpc.hub_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    # nat_gateway_id = data.aws_nat_gateway.nat_gw.id
    # nat_gateway_id = element(tolist(data.aws_nat_gateways.nat_gw.ids), 0)
    nat_gateway_id = lookup(local.az_to_nat_gw_id, data.aws_subnet.ind_fw_subnet[each.value].availability_zone, null)
  }

  route {
    cidr_block = "20.0.0.0/16"
    transit_gateway_id = data.aws_ec2_transit_gateway.tgw.id
  }

  tags = {
    Name = "${var.env}-public"
  }
}

resource "aws_route_table_association" "fw_assoc" {
  for_each       = toset(data.aws_subnets.fw_subnets_details.ids)
  
  subnet_id      = each.value
  # route_table_id = aws_route_table.fw_rt[each.value].id
  route_table_id = aws_route_table.fw_rt.id
}