resource "aws_ec2_transit_gateway" "this" {
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation

  tags = {
    Name = "hub-${var.env}-tgw"
    NetworkTier = "hub-tgw"
  }
}