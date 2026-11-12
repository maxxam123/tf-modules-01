resource "aws_security_group" "hub_nlb" {
  name        = "${var.env}-hub-nlb-sg"
  description = "Allow incoming HTTP traffic to Hub NLB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic to Spoke ALB"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "hub_nlb" {
  name                             = "${var.env}-hub-nlb"
  internal                         = false
  load_balancer_type               = "network"
  subnets                          = var.pub_subnet_id
  enable_cross_zone_load_balancing = true

  security_groups = [aws_security_group.hub_nlb.id]

  tags = {
    Name = "hub-${var.env}-lb"
    NetworkTier = "hub-lb"
  }
}

resource "aws_lb_target_group" "spoke_alb" {
  name        = "${var.env}-hub-to-spoke-alb-tg"
  port        = 80
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "alb"

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    port                = "80"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }
}

resource "aws_lb_target_group_attachment" "spoke_alb" {
  target_group_arn = aws_lb_target_group.spoke_alb.arn
  target_id        = var.spoke_alb_arn
  port             = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.hub_nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.spoke_alb.arn
  }
}
