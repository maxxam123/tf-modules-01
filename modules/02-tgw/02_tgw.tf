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
  vpc_id             = var.vpc_id
  subnet_ids         = var.tgw_subnet_id

  dns_support  = "enable"
  appliance_mode_support = "disable"

  tags = {
    Name = "hub-${var.env}-tgw-attach"
    NetworkTier = "hub-tgw-attach"
  }
}