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
  vpc_id              = module.vpc.vpc_id # Attaches to your Hub VPC

  # Dynamic loop turns a list of subnet strings into multiple AWS mapping blocks
  dynamic "subnet_mapping" {
    for_each = var.fw_id
    content {
      subnet_id = subnet_mapping.value
    }
  }
}
