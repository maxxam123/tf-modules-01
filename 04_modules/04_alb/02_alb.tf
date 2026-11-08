data "aws_vpc" "hub_vpc" {
  filter {
    name   = "tag:Name"
    values = ["dev-vpc"]
  }
}

data "aws_subnets" "pub_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.hub_vpc.id]
  }

  filter {
    name   = "tag:NetworkTier"
    values = ["pub"]
  }
}

resource "aws_security_group" "alb" {
  name        = "${var.name}-sg"
  vpc_id      = data.aws_vpc.hub_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "this" {
  name               = var.name
  internal           = false 
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.pub_subnets.ids

  enable_deletion_protection = var.env == "prod" ? true : false

  tags = {
    Name = "hub-${var.env}-lb"
    NetworkTier = "hub-lb"
  }
}

resource "aws_lb_target_group" "default" {
  name        = "${var.name}-tg-default"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.hub_vpc.id
  target_type = "ip" 

  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group_attachment" "default" {
  target_group_arn = aws_lb_target_group.default.arn
  target_id        = "10.1.10.45"
  port             = 8080
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06" # Modern TLS 1.3 policy
  certificate_arn   = "arn:aws:acm:us-east-1:123456789012:certificate/placeholder" # Replace or pass as var

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}

resource "aws_lb_listener_rule" "default_listener_rule" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  condition {
    host_header {
      values = ["mycompany.com"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}
