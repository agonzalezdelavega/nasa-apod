# ECS Cluster

resource "aws_ecs_cluster" "nasa-apod" {
  name = "${local.prefix}-cluster"
}

resource "aws_cloudwatch_log_group" "ecs_task_logs" {
  name = "${local.prefix}-logs"
}

data "aws_ecr_image" "nasa-apod-image" {
  repository_name = "nasa-apod"
  image_tag       = "latest"
}

resource "random_string" "express_secret" {
  length = 16
}

data "aws_ssm_parameter" "api-key" {
  name = "nasa-api-key"
}

data "template_file" "ecs_container_definition" {
  template = file("./templates/ecs/container-definition.json.tpl")
  vars = {
    app_image                         = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${data.aws_ecr_image.nasa-apod-image.repository_name}:latest",
    log_group_name                    = aws_cloudwatch_log_group.ecs_task_logs.name,
    aws_region                        = data.aws_region.current.name,
    cognito_url                       = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${data.aws_region.current.name}.amazoncognito.com/login?response_type=code&client_id=${aws_cognito_user_pool_client.app-client.id}&redirect_uri=https%3A%2F%2F${aws_route53_record.app.fqdn}",
    cognito_client_id                 = aws_cognito_user_pool_client.app-client.id,
    user_pool_id                      = aws_cognito_user_pool.user_pool.id,
    dynamo_db_sessions_table_name     = "nasa-apod-dynamo-db-sessions",
    dynamo_db_sessions_partition_key  = "sessionID",
    dynamo_db_favorites_table_name    = aws_dynamodb_table.nasa-apod-favorites.name,
    dynamo_db_favorites_partition_key = aws_dynamodb_table.nasa-apod-favorites.hash_key,
    dynamo_db_endpoint                = "dynamodb.${data.aws_region.current.name}.amazonaws.com",
    express_session_secret            = random_string.express_secret.result,
    api_key                           = data.aws_ssm_parameter.api-key.value
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
  name                   = "${local.prefix}-service"
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