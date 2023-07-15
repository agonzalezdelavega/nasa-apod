resource "aws_lb" "apod_lb" {
  name               = "${var.prefix}-load-balancer"
  load_balancer_type = "application"
  subnets = [
    aws_subnet.public-2a.id,
    aws_subnet.public-2b.id
  ]
  security_groups = [aws_security_group.elb.id]
}

resource "aws_lb_target_group" "alb-target-group" {
  name        = "${var.prefix}-alb-target-group"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  port        = 3000
  health_check {
    path = "/"
    matcher = "302"
  }
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.apod_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-target-group.arn
  }
}