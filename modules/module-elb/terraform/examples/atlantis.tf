provider "aws" {
  region = var.region
}

locals {
  # determine if the alb has authentication enabled, otherwise forward the traffic unauthenticated
  alb_authenication_method = length(keys(var.alb_authenticate_oidc)) > 0 ? "authenticate-oidc" : length(keys(var.alb_authenticate_cognito)) > 0 ? "authenticate-cognito" : "forward"

}

module "alb" {
  source  = "../"

  name     = var.name
  internal = var.internal

  vpc_id          = "vpc-0444bb60d7014f23b"
  subnets         = ["subnet-0b20f10df45d7c99d", "subnet-049a76b8745b77c2c", "subnet-0687e035183b4b400"]
  security_groups = ["sg-009f9ed14ac03331f"]

  access_logs = {
    enabled = var.alb_logging_enabled
    bucket  = var.alb_log_bucket_name
    prefix  = var.alb_log_location_prefix
  }

  enable_deletion_protection = var.alb_enable_deletion_protection

  drop_invalid_header_fields = var.alb_drop_invalid_header_fields

  listener_ssl_policy_default = var.alb_listener_ssl_policy_default
  https_listeners = [
    {
      target_group_index   = 0
      port                 = 443
      protocol             = "HTTPS"
      certificate_arn      = "arn:aws:acm:eu-west-1:245262601703:certificate/7d716080-bb7b-4086-a803-ca99dbf64626"
      action_type          = local.alb_authenication_method
      authenticate_oidc    = var.alb_authenticate_oidc
      authenticate_cognito = var.alb_authenticate_cognito
    },
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = 443
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
  ]

  target_groups = [
    {
      name                 = var.name
      backend_protocol     = "HTTP"
      backend_port         = "4141"
      target_type          = "ip"
      deregistration_delay = 10
    },
  ]

  tags = var.tags
}
