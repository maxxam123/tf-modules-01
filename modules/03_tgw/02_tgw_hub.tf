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

data "aws_subnets" "hub_tgw_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.hub_vpc.id]
  }

  filter {
    name   = "tag:NetworkTier"
    values = ["hub-tgw-subnet"]
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "hub" {
  transit_gateway_id = data.aws_ec2_transit_gateway.hub_tgw.id
  vpc_id             = data.aws_vpc.hub_vpc.id
  subnet_ids         = data.aws_subnets.hub_tgw_subnets.ids

  dns_support  = "enable"
  appliance_mode_support = "disable"

  tags = {
    Name = "hub-${var.env}-tgw-attach"
    NetworkTier = "hub-tgw-attach"
  }
}

resource "aws_ec2_transit_gateway_route_table" "hub" {
  transit_gateway_id = data.aws_ec2_transit_gateway.hub_tgw.id
  
  tags               = {
    Name = "hub-${var.env}-tgw-rt"
    NetworkTier = "hub-tgw-rt" 
    }
}

resource "aws_ec2_transit_gateway_route_table_association" "hub" {        
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hub.id
}
