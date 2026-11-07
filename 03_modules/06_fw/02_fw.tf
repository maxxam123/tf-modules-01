data "aws_vpc" "hub_vpc" {
  filter {
    name   = "tag:Name"
    values = ["dev-vpc"]
  }
}

data "aws_subnets" "fw_subnets_details" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.hub_vpc.id]
  }

  filter {
    name   = "tag:network"
    values = ["fw"]
  }
}

data "aws_subnet" "fw_subnets" {
  for_each = toset(data.aws_subnets.fw_subnets_details.ids)
  id       = each.value
}

locals {
  fw_subnet_map = {
    for s in data.aws_subnet.fw_subnets : s.availability_zone => s.id
  }
}

resource "aws_networkfirewall_rule_group" "block_domains" {
  capacity = 100
  name     = "${var.env}-block-domains"
  type     = "STATEFUL"

  rule_group {
    rules_source {
      rules_source_list {
        generated_rules_type = "DENYLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets              = ["malicious-example.com", "unauthorized-api.net"]
      }
    }
  }
}

resource "aws_networkfirewall_firewall_policy" "this" {
  name = "${var.env}-firewall-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.block_domains.arn
    }
  }
}

resource "aws_networkfirewall_firewall" "this" {
  name                = "${var.env}-hub-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.this.arn
  vpc_id              = data.aws_vpc.hub_vpc.id

  dynamic "subnet_mapping" {
    for_each = local.fw_subnet_map
    content {
      subnet_id       = subnet_mapping.value
      ip_address_type = "DUALSTACK" # Enterprise compliance standard for IPv4/IPv6 support
    }
  }
}
