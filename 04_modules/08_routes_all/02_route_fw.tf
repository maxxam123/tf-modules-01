data "aws_internet_gateway" "hub_igw" {
  filter {
    name   = "tag:NetworkTier"
    values = ["hub-igw"]
  }
}

data "aws_vpc" "hub_vpc" {
  filter {
    name   = "tag:NetworkTier"
    values = ["hub-vpc"]
  }
}

data "aws_subnets" "tgw_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.hub_vpc.id]
  }

  filter {
    name   = "tag:NetworkTier"
    values = ["hub-tgw-subnet"]
  }
}

data "aws_subnets" "pub_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.hub_vpc.id]
  }

  filter {
    name   = "tag:NetworkTier"
    values = ["hub-pub-subnet"]
  }
}

data "aws_subnet" "ind_pub_subnet" {
  for_each = toset(data.aws_subnets.pub_subnets.ids)
  id       = each.value
}

data "aws_subnet" "ind_tgw_subnet" {
  for_each = toset(data.aws_subnets.tgw_subnets.ids)
  id       = each.value
}

data "aws_resourcegroupstaggingapi_resources" "hub_nfw_search" {
  resource_type_filters = ["networkfirewall:firewall"]

  tag_filter {
    key    = "NetworkTier"
    values = ["hub-fw"] 
  }
}

data "aws_networkfirewall_firewall" "hub_nfw" {
  arn = data.aws_resourcegroupstaggingapi_resources.hub_nfw_search.resource_tag_mapping_list[0].resource_arn
}

locals {
  nfw_az_to_endpoint = {
    for state in flatten([
      for status_block in data.aws_networkfirewall_firewall.hub_nfw.firewall_status : status_block.sync_states
    ]) : state.availability_zone => one(state.attachment[*].endpoint_id)
  }
}

resource "aws_route_table" "hub_tgw_rt" {
  # for_each = toset(data.aws_subnets.tgw_subnets.ids)
  for_each = toset(var.availability_zones)
  vpc_id   = data.aws_vpc.hub_vpc.id
}

resource "aws_route" "tgw_route" {
  for_each = toset(data.aws_subnets.tgw_subnets.ids)

  route_table_id = aws_route_table.hub_tgw_rt[data.aws_subnet.ind_tgw_subnet[each.value].availability_zone].id
  # route_table_id = aws_route_table.hub_tgw_rt[each.value].id
  

  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = lookup(local.nfw_az_to_endpoint, data.aws_subnet.ind_tgw_subnet[each.value].availability_zone, null)

  lifecycle {
    precondition {
      condition     = lookup(local.nfw_az_to_endpoint, data.aws_subnet.ind_tgw_subnet[each.value].availability_zone, null) != null
      error_message = "The Network Firewall Endpoint for AZ ${data.aws_subnet.ind_tgw_subnet[each.value].availability_zone} is not provisioned or active."
    }
  }
}

resource "aws_route_table_association" "hub_tgw_rt_assoc" {
  for_each = toset(data.aws_subnets.tgw_subnets.ids)

  subnet_id      = each.value
  # route_table_id = aws_route_table.hub_tgw_rt[data.aws_subnet.ind_tgw_subnet[each.value].availability_zone].id
  route_table_id = aws_route_table.hub_tgw_rt[data.aws_subnet.ind_tgw_subnet[each.value].availability_zone].id
  # route_table_id = aws_route_table.hub_tgw_rt[each.value].id
}


resource "aws_route_table" "hub_igw_rt" {
  vpc_id = data.aws_vpc.hub_vpc.id
}

resource "aws_route_table_association" "igw_ingress_assoc" {
  gateway_id     = data.aws_internet_gateway.hub_igw.id
  route_table_id = aws_route_table.hub_igw_rt.id
}

resource "aws_route" "igw_route" {
  for_each = toset(data.aws_subnets.pub_subnets.ids)

  route_table_id         = aws_route_table.hub_igw_rt.id
  destination_cidr_block = data.aws_subnet.ind_pub_subnet[each.value].cidr_block
  # destination_cidr_block = "10.0.0.0/16"

  vpc_endpoint_id        = lookup(local.nfw_az_to_endpoint, data.aws_subnet.ind_pub_subnet[each.value].availability_zone, null)

  lifecycle {
    precondition {
      condition     = lookup(local.nfw_az_to_endpoint, data.aws_subnet.ind_pub_subnet[each.value].availability_zone, null) != null
      error_message = "The Network Firewall Endpoint for AZ ${data.aws_subnet.ind_pub_subnet[each.value].availability_zone} is not provisioned or active."
    }
  }
}