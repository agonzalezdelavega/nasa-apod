resource "aws_lb" "apod_lb" {
  name               = "${local.prefix}-load-balancer"
  load_balancer_type = "application"
  subnets = [
    aws_subnet.public-2a.id,
    aws_subnet.public-2b.id
  ]
  security_groups = [aws_security_group.elb.id]
}

resource "aws_lb_target_group" "alb-target-group" {
  name        = "${local.prefix}-alb-target-group"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  port        = 3000
  health_check {
    path     = "/health"
    matcher  = "200"
    port     = 3000
    interval = 90
  }
  stickiness {
    type        = "app_cookie"
    cookie_name = "nasa-apod"
    enabled     = true
  }
}

resource "aws_lb_listener" "app_http" {
  load_balancer_arn = aws_lb.apod_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "app_https" {
  load_balancer_arn = aws_lb.apod_lb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate_validation.cert.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-target-group.arn
  }
}