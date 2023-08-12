resource "aws_dynamodb_table" "nasa-apod-sessions" {
  name           = "${local.prefix}-dynamo-db-sessions"
  hash_key       = "sessionID"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  attribute {
    name = "sessionID"
    type = "S"
  }
  ttl {
    attribute_name = "expires"
    enabled        = true
  }
}