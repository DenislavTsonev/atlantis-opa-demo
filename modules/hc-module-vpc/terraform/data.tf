data "aws_region" "current" {}
data "external" "get_module_git_url" {
  program     = ["python3", "./helpers/get_git_url.py"]
  working_dir = path.module
}

data "aws_ec2_transit_gateway" "networking" {
  count = var.tgw_id != "" && var.tgw_resource == null ? 1 : 0
  id    = var.tgw_id
}
