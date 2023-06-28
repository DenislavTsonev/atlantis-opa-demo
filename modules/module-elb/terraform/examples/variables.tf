variable "region" {
  type = string
  description = "AWS Region"
  default = "eu-west-1"
}

variable "name" {
  description = "Name to use on all resources created (VPC, ALB, etc)"
  type        = string
  default     = "atlantis"
}

variable "internal" {
  description = "Whether the load balancer is internal or external"
  type        = bool
  default     = false
}

variable "alb_log_bucket_name" {
  description = "S3 bucket (externally created) for storing load balancer access logs. Required if alb_logging_enabled is true."
  type        = string
  default     = ""
}

variable "alb_log_location_prefix" {
  description = "S3 prefix within the log_bucket_name under which logs are stored."
  type        = string
  default     = ""
}

variable "alb_logging_enabled" {
  description = "Controls if the ALB will log requests to S3."
  type        = bool
  default     = false
}

variable "alb_authenticate_oidc" {
  description = "Map of Authenticate OIDC parameters to protect ALB (eg, using Auth0). See https://www.terraform.io/docs/providers/aws/r/lb_listener.html#authenticate-oidc-action"
  type        = any
  default     = {}
}

variable "alb_authenticate_cognito" {
  description = "Map of AWS Cognito authentication parameters to protect ALB (eg, using SAML). See https://www.terraform.io/docs/providers/aws/r/lb_listener.html#authenticate-cognito-action"
  type        = any
  default     = {}
}

variable "alb_enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false."
  type        = bool
  default     = null
}

variable "alb_drop_invalid_header_fields" {
  description = "Indicates whether invalid header fields are dropped in application load balancers. Defaults to false."
  type        = bool
  default     = null
}

variable "allow_unauthenticated_access" {
  description = "Whether to create ALB listener rule to allow unauthenticated access for certain CIDR blocks (eg. allow GitHub webhooks to bypass OIDC authentication)"
  type        = bool
  default     = false
}

variable "allow_unauthenticated_access_priority" {
  description = "ALB listener rule priority for allow unauthenticated access rule"
  type        = number
  default     = 10
}

variable "whitelist_unauthenticated_cidr_blocks" {
  description = "List of allowed CIDR blocks to bypass authentication"
  type        = list(string)
  default     = []
}

variable "alb_listener_ssl_policy_default" {
  description = "The security policy if using HTTPS externally on the load balancer. [See](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html)."
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
}


variable "security_group_ids" {
  description = "List of one or more security groups to be added to the load balancer"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
