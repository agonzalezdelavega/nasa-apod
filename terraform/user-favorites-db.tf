resource "aws_dynamodb_table" "nasa-apod-favorites" {
  name           = "${local.prefix}-dynamo-db-favorites"
  hash_key       = "userID"
  billing_mode   = "PROVISIONED"
  read_capacity  = 2
  write_capacity = 1
  attribute {
    name = "userID"
    type = "S"
  }
}
