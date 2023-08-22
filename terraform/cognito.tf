resource "aws_cognito_user_pool" "user_pool" {
  name = "${local.prefix}-user-pool"

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

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_symbols   = true
    require_numbers   = true
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true
  }

  lambda_config {
    post_confirmation = aws_lambda_function.user_post_signup.arn
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
  domain       = "${local.prefix}-${random_id.user_pool_domain_id.hex}"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}

resource "aws_cognito_user_pool_client" "app-client" {
  name                                 = "${local.prefix}-app-client"
  user_pool_id                         = aws_cognito_user_pool.user_pool.id
  callback_urls                        = ["https://${aws_route53_record.app.fqdn}"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid"]
  supported_identity_providers         = ["COGNITO"]
  explicit_auth_flows                  = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
}

# Lambda trigger permissions

resource "aws_lambda_permission" "post-confirmation-trigger" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.user_post_signup.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.user_pool.arn
}