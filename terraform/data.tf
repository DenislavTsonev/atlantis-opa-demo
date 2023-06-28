data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_route53_zone" "this" {
  count = var.create_route53_record ? 1 : 0

  name         = var.route53_zone_name
}
