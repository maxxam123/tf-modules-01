data "aws_vpc" "hub_vpc" {
  filter {
    name   = "tag:NetworkTier"
    values = ["hub-vpc"]
  }
}

data "aws_lb" "hub_alb" {
  tags = {
    NetworkTier = "hub-lb"
  }
}

resource "aws_route53_zone" "primary" {
  name          = "mycompany.com"
  force_destroy = false

    vpc {
    vpc_id     = data.aws_vpc.hub_vpc.id
    vpc_region = "us-east-1"
  }
}

resource "aws_route53_record" "app_alias" {
  zone_id = aws_route53_zone.primary.id

  name    = "mycompany.com"
  type    = "A"

  alias {
    name                   = data.aws_lb.hub_alb.dns_name
    zone_id                = data.aws_lb.hub_alb.zone_id
    evaluate_target_health = true
  }
}