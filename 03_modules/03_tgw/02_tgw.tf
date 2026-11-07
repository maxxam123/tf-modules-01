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


resource "aws_ec2_transit_gateway" "this" {
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation

  tags = {
    Name = "${var.env}-tgw"
    "tgw" = "tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "hub" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = data.aws_vpc.hub_vpc.id
  subnet_ids         = data.aws_subnets.tgw_subnets.ids

  dns_support  = "enable"
  appliance_mode_support = "disable" # enable ONLY IF Firewall

  tags = {
    Name = "${var.env}-tgw-hub-attach"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = data.aws_vpc.hub_vpc.id
  subnet_ids         = data.aws_subnets.tgw_subnets.ids

  dns_support  = "enable"
  appliance_mode_support = "disable" # enable ONLY IF Firewall

  tags = {
    Name = "${var.env}-tgw-spoke-attach"
  }
}

resource "aws_ec2_transit_gateway_route_table" "hub" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  tags               = { Name = "dev-tgw-rt-hub" }
}

resource "aws_ec2_transit_gateway_route_table" "spoke" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  tags               = { Name = "dev-tgw-rt-spoke" }
}

resource "aws_ec2_transit_gateway_route_table_association" "hub" {        
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hub.id
}

resource "aws_ec2_transit_gateway_route_table_association" "spoke" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "hub_to_spoke" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hub.id
}

resource "aws_ec2_transit_gateway_route" "spoke_default" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}
