data "aws_vpc" "hub_vpc" {
  filter {
    name   = "tag:NetworkTier"
    values = ["hub-vpc"]
  }
}

data "aws_subnets" "hub_tgw_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.hub_vpc.id]
  }

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
    values = ["spoke-tgw"]
  }
}


resource "aws_ec2_transit_gateway" "this" {
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation

  tags = {
    Name = "hub-${var.env}-tgw"
    NetworkTier = "hub-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "hub" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = data.aws_vpc.hub_vpc.id
  subnet_ids         = data.aws_subnets.hub_tgw_subnets.ids

  dns_support  = "enable"
  appliance_mode_support = "disable"

  tags = {
    Name = "hub-${var.env}-tgw-attach"
    NetworkTier = "hub-tgw-attach"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = data.aws_vpc.hub_vpc.id
  subnet_ids         = data.aws_subnets.spoke_tgw_subnets.ids

  dns_support  = "enable"
  appliance_mode_support = "disable"

  tags = {
    Name = "spoke-${var.env}-tgw-attach"
    NetworkTier = "spoke-tgw-attach"
  }
}

resource "aws_ec2_transit_gateway_route_table" "hub" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  tags               = {
    Name = "hub-${var.env}-tgw-rt"
    NetworkTier = "hub-tgw-rt" 
    }
}

resource "aws_ec2_transit_gateway_route_table" "spoke" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  tags               = {
    Name = "spoke-${var.env}-tgw-rt"
    NetworkTier = "spoke-tgw-rt"
    }
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
