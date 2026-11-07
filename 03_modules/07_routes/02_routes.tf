data "aws_vpc" "hub_vpc" {
  filter {
    name   = "tag:Name"
    values = ["dev-vpc"] # 🔍 Searches all VPCs in your AWS account for this exact Name tag
  }
}

data "aws_subnets" "tgw_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.hub_vpc.id] # 1. Only look inside the VPC we just found above
  }

  filter {
    name   = "tag:network"
    values = ["tgw"] # 2. Only grab subnets that have this custom tier tag
  }
}

data "aws_subnets" "fw_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.hub_vpc.id] # 1. Only look inside the VPC we just found above
  }

  filter {
    name   = "tag:network"
    values = ["fw"] # 2. Only grab subnets that have this custom tier tag
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.hub_vpc.id] # 1. Only look inside the VPC we just found above
  }

  filter {
    name   = "tag:network"
    values = ["public"]
  }
}

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

resource "aws_route_table" "public" {
  vpc_id = data.aws_vpc.hub_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  route {
    cidr_block = "20.0.0.0/16"
    transit_gateway_id = var.tgw_01_id
  }

  tags = {
    Name = "${var.env}-public"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = data.aws_subnet.fw_subnets.ids
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "tgw_rt_01" {
  vpc_id = data.aws_vpc.hub_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    vpc_endpoint_id = 
  }
}
 
resource "aws_route_table" "tgw_rt_02" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    vpc_endpoint_id = module.fw.fw_id[1]
  }
}

resource "aws_route_table" "fw_rt" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = module.vpc.nat_id
  }

  route {
    cidr_block = "20.0.0.0/16"
    transit_gateway_id = module.tgw.tgw_id
  }
}

resource "aws_route_table" "pub_rt" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "10.0.0.0/16"
    vpc_endpoint_id = module.fw.fw_id[0]
  }
  route {
    cidr_block = "10.0.0.0/16"
    vpc_endpoint_id = module.fw.fw_id[1]
  }
}

resource "aws_route_table_association" "igw_rt_assoc" {
  gateway_id     = module.vpc.igw_id    # The IGW ID goes here
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "fw_rt_assoc" {
  subnet_id      = module.vpc.fw_id[0]
  route_table_id = aws_route_table.fw_rt.id
}

resource "aws_route_table_association" "fw_rt_assoc" {
  subnet_id      = module.vpc.fw_id[1]
  route_table_id = aws_route_table.fw_rt.id
}

resource "aws_route_table_association" "tgw_01_rt_assoc" {
  subnet_id      = module.vpc.tgw_id[0]
  route_table_id = aws_route_table.tgw_rt_01.id
}

resource "aws_route_table_association" "tgw_02_rt_assoc" {
  subnet_id      = module.vpc.tgw_id[1]
  route_table_id = aws_route_table.tgw_rt_02.id
}