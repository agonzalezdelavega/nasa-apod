resource "aws_cognito_user_pool" "user_pool" {
  name = "${var.prefix}-user-pool"

  auto_verified_attributes = ["email"]

  username_attributes = ["email"]

  verification_message_template {
    default_email_option = "CONFIRM_WITH_LINK"
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true
  }

  password_policy {
    minimum_length    = 8
    require_lowercase = false
    require_numbers   = false
    require_symbols   = false
    require_uppercase = false
  }

  lifecycle {
    ignore_changes = [
      schema
    ]
  }
}

resource "random_id" "user_pool_domain_id" {
  byte_length = 8
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.prefix}-${random_id.user_pool_domain_id.hex}"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}

resource "aws_cognito_user_pool_client" "app-client" {
  name                                 = "${var.prefix}-app-client"
  user_pool_id                         = aws_cognito_user_pool.user_pool.id
  callback_urls                        = ["https://${aws_route53_record.app.fqdn}"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid"]
  supported_identity_providers         = ["COGNITO"]
  explicit_auth_flows                  = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
}