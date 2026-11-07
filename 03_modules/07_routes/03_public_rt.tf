data "aws_internet_gateway" "hub_igw" {
  filter {
    name   = "tag:igw"
    values = ["igw"]
  }
}

data "aws_ec2_transit_gateway" "hub_tgw" {
  filter {
    name   = "tag:tgw"
    values = ["tgw"]
  }
}

data "aws_vpc" "hub_vpc" {
  filter {
    name   = "tag:Name"
    values = ["dev-vpc"] # 🔍 Searches all VPCs in your AWS account for this exact Name tag
  }
}

data "aws_subnets" "public_subnets_details" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.hub_vpc.id] # 1. Only look inside the VPC we just found above
  }

  filter {
    name   = "tag:network"
    values = ["pulic"] # 2. Only grab subnets that have this custom tier tag
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

