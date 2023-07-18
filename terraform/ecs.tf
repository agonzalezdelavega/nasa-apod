# ECS Cluster

resource "aws_ecs_cluster" "nasa-apod" {
  name = "${var.prefix}-cluster"
}

data "aws_cloudwatch_log_group" "ecs_task_logs" {
  name = "nasa-apod-logs"
}

data "aws_ecr_image" "nasa-apod-image" {
  repository_name = "nasa-apod"
  image_tag       = "latest"
}

data "template_file" "ecs_container_definition" {
  template = file("./templates/ecs/container-definition.json.tpl")
  vars = {
    app_image        = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${data.aws_ecr_image.nasa-apod-image.repository_name}:latest",
    log_group_name   = data.aws_cloudwatch_log_group.ecs_task_logs.name,
    log_group_region = data.aws_region.current.name,
    aws_region       = data.aws_region.current.name,
    cognito_url      = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${data.aws_region.current.name}.amazoncognito.com/login?response_type=code&client_id=${aws_cognito_user_pool_client.app-client.id}&redirect_uri=https%3A%2F%2F${aws_route53_record.app.fqdn}"
  }
}

resource "aws_ecs_task_definition" "apod_app" {
  family                   = "nasa-apod"
  container_definitions    = data.template_file.ecs_container_definition.rendered
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.nasa-apod-task-execution-role.arn
  task_role_arn            = aws_iam_role.nasa-apod-task-role.arn
}

# ECS Service

resource "aws_ecs_service" "apod" {
  name                   = "${var.prefix}-service"
  cluster                = aws_ecs_cluster.nasa-apod.name
  task_definition        = aws_ecs_task_definition.apod_app.family
  desired_count          = 2
  launch_type            = "FARGATE"
  platform_version       = "1.4.0"
  enable_execute_command = true
  network_configuration {
    subnets = [
      aws_subnet.private-2a.id,
      aws_subnet.private-2b.id
    ]
    security_groups = [aws_security_group.ecs_service.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.alb-target-group.arn
    container_name   = "nasa-apod"
    container_port   = 3000
  }
}