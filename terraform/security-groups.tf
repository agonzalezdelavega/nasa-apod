# Load Balancer

resource "aws_security_group" "elb" {
  name   = "${local.prefix}-elb"
  vpc_id = aws_vpc.main.id
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
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    security_groups = [
      aws_security_group.nat.id,
      aws_security_group.ecs_service.id
    ]
  }
}

# NAT Instances

resource "aws_security_group" "nat" {
  name   = "${local.prefix}-nat"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_security_group_ingress_rule" "nat_ingress_elb" {
  security_group_id = aws_security_group.nat.id
  referenced_security_group_id = aws_security_group.elb.id
  from_port   = 3000
  to_port     = 3000
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "nat_ingress_ecs" {
  security_group_id = aws_security_group.nat.id
  referenced_security_group_id = aws_security_group.ecs_service.id
  from_port   = 3000
  to_port     = 3000
  ip_protocol = "tcp"
}

# ECS

resource "aws_security_group" "ecs_service" {
  name   = "${local.prefix}-ecs"
  vpc_id = aws_vpc.main.id
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.nat.id]
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_ingress_elb" {
  security_group_id = aws_security_group.ecs_service.id
  referenced_security_group_id = aws_security_group.elb.id
  from_port   = 3000
  to_port     = 3000
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ecs_ingress_nat" {
  security_group_id = aws_security_group.ecs_service.id
  referenced_security_group_id = aws_security_group.nat.id
  from_port   = 3000
  to_port     = 3000
  ip_protocol = "tcp"
}