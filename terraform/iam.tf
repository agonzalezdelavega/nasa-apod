# ECS Task Execution Role

resource "aws_iam_role" "nasa-apod-task-execution-role" {
  name = "${var.prefix}-task-execution-role"
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
  name = "${var.prefix}-task-role"
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

resource "aws_iam_policy" "apod-lambda-allow-ssm" {
  name   = "${aws_iam_role.nasa-apod-task-role.name}-allow-ssm"
  policy = file("./templates/iam/ecs-task-role-policy.json")
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-attachment" {
  role       = aws_iam_role.nasa-apod-task-role.name
  policy_arn = aws_iam_policy.apod-lambda-allow-ssm.arn
}
