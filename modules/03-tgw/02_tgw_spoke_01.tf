data "aws_ec2_transit_gateway_vpc_attachment" "hub_tgw_attachment" {
  filter {
    name   = "tag:NetworkTier"
    values = ["hub-tgw-attachment"]
  }
}

data "aws_ec2_transit_gateway_route_table" "hub_tgw_rt" {
  filter {
    name   = "tag:NetworkTier"
    values = ["hub-tgw-rt"]
  }
}

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

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  transit_gateway_id = data.aws_ec2_transit_gateway.hub_tgw.id
  vpc_id             = data.aws_vpc.spoke_vpc.id
  subnet_ids         = data.aws_subnets.spoke_tgw_subnets.ids

  dns_support  = "enable"
  appliance_mode_support = "disable"

  tags = {
    Name = "spoke-${var.env}-tgw-attach"
    NetworkTier = "spoke-tgw-attach"
  }
}

resource "aws_ec2_transit_gateway_route_table" "this" {
  transit_gateway_id = data.aws_ec2_transit_gateway.hub_tgw.id
  tags               = {
    Name = "spoke-${var.env}-tgw-rt"
    NetworkTier = "spoke-tgw-rt"
    }
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.hub_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route" "this" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.hub_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}