# ECS Task Execution Role

resource "aws_iam_role" "nasa-apod-task-execution-role" {
  name = "${local.prefix}-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AssumeLambdaRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "nasa-apod-task-execution-policy" {
  name   = "${aws_iam_role.nasa-apod-task-execution-role.name}-policy"
  policy = file("./templates/iam/ecs-task-execution-role-policy.json")
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-attachment" {
  role       = aws_iam_role.nasa-apod-task-execution-role.name
  policy_arn = aws_iam_policy.nasa-apod-task-execution-policy.arn
}

# ECS Task Role

resource "aws_iam_role" "nasa-apod-task-role" {
  name = "${local.prefix}-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AssumeLambdaRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_kms_key" "api-kms-key" {
  key_id = "alias/${var.api_key_kms_key}"
}

data "aws_secretsmanager_secret" "api-key" {
  name = var.api_key_secretsmanager_name
}

data "template_file" "task_role_policy" {
  template = file("./templates/iam/ecs-task-role-policy.json.tpl")
  vars = {
    aws_region                     = data.aws_region.current.name,
    account                        = data.aws_caller_identity.current.account_id,
    dynamo_db_sessions_table_name  = "nasa-apod-dynamo-db-sessions",
    dynamo_db_favorites_table_name = aws_dynamodb_table.nasa-apod-favorites.name,
    kms_key_arn                    = data.aws_kms_key.api-kms-key.arn,
    api_key_arn                    = data.aws_secretsmanager_secret.api-key.arn
  }
}

resource "aws_iam_policy" "apod-lambda-allow-ssm" {
  name   = "${aws_iam_role.nasa-apod-task-role.name}-allow-ssm"
  policy = data.template_file.task_role_policy.rendered
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-attachment" {
  role       = aws_iam_role.nasa-apod-task-role.name
  policy_arn = aws_iam_policy.apod-lambda-allow-ssm.arn
}

# NAT Instances

resource "aws_iam_role" "nat" {
  name = "${local.prefix}-nat-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AssumeLambdaRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

data "template_file" "nat_task_role_policy" {
  template = file("./templates/iam/nat-instance-profile.json.tpl")
  vars = {
    aws_region       = data.aws_region.current.name,
    account          = data.aws_caller_identity.current.account_id,
    eip-allocation-a = aws_eip.eip-2a.allocation_id
    eip-allocation-b = aws_eip.eip-2b.allocation_id
  }
}

resource "aws_iam_policy" "nat-iam-policy" {
  name   = "${local.prefix}-nat-policy"
  policy = data.template_file.nat_task_role_policy.rendered
}

resource "aws_iam_role_policy_attachment" "nat-iam-policy-attachment" {
  role       = aws_iam_role.nat.name
  policy_arn = aws_iam_policy.nat-iam-policy.arn
}