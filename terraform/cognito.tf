resource "aws_cognito_user_pool" "user_pool" {
  name = "nasa-apod-user-pool"

  auto_verified_attributes = ["email"]

  alias_attributes = ["email"]

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

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }
  lifecycle {
    ignore_changes = [
      schema
    ]
  }
}

resource "random_id" "user_pool_domain_id" {
  byte_length = 2
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
}