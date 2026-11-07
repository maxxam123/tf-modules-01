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

data "aws_nat_gateway" "nat_gw" {
  filter {
    name = "tag:nat"
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

resource "aws_route_table" "fw_rt" {
  vpc_id = data.aws_vpc.hub_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = data.aws_nat_gateway.nat_gw.id
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
  route_table_id = aws_route_table.fw_rt[each.value].id
}