resource "aws_lambda_function" "user_post_signup" {
  function_name = "${local.prefix}-user-post-signup"
  filename      = "./lambda/post-user-signup.zip"
  role          = aws_iam_role.lambda-post-user-signup.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  environment {
    variables = {
      DYNAMO_DB_FAVORITES_TABLE_NAME = aws_dynamodb_table.nasa-apod-favorites.name
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.lambda-post-user-signup.id]
    subnet_ids = [
      aws_subnet.private-2a.id,
      aws_subnet.private-2b.id
    ]
  }
}