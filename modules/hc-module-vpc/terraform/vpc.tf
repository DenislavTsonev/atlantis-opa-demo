######
# VPC
######
resource "aws_vpc" "this" {
  count = var.create_vpc ? 1 : 0

  cidr_block           = var.cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    {
      Name = local.vpc_name
      //      TFModule        = local.module_git_url
      TFModuleVersion = local.module_version
      TFModuleName    = local.module_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "vpcs", {}),
    lookup(local.tags, "vpc_this", {})
  )
}

resource "aws_default_security_group" "this" {
  count = var.create_vpc ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      Name = "vpc-default-sg"
      //      TFModule        = local.module_git_url
      TFModuleVersion = local.module_version
      TFModuleName    = local.module_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "security_groups", {}),
    lookup(local.tags, "security_group_default", {})
  )
}

###################
# DHCP Options Set
###################
resource "aws_vpc_dhcp_options" "this" {
  count = var.create_vpc && var.enable_dhcp_options ? 1 : 0

  domain_name          = var.dhcp_options_domain_name
  domain_name_servers  = var.dhcp_options_domain_name_servers
  ntp_servers          = var.dhcp_options_ntp_servers
  netbios_name_servers = var.dhcp_options_netbios_name_servers
  netbios_node_type    = var.dhcp_options_netbios_node_type

  tags = merge(
    {
      Name = local.dhcp_options_name
      //      TFModule        = local.module_git_url
      TFModuleVersion = local.module_version
      TFModuleName    = local.module_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "dhcp_options", {}),
    lookup(local.tags, "dhcp_options_this", {})
  )
}

###############################
# DHCP Options Set Association
###############################
resource "aws_vpc_dhcp_options_association" "this" {
  count = var.create_vpc && var.enable_dhcp_options ? 1 : 0

  vpc_id          = aws_vpc.this[0].id
  dhcp_options_id = aws_vpc_dhcp_options.this[count.index].id
}

################
# VPC flow logs
################

resource "aws_flow_log" "vpc_flow_log" {
  count = var.create_vpc ? 1 : 0

  vpc_id          = aws_vpc.this[count.index].id
  iam_role_arn    = var.flowlogs_role_name != "" ? var.flowlogs_role_name : aws_iam_role.vpc_flowlogs_role[count.index].arn
  log_destination = aws_cloudwatch_log_group.vpc_log_group[count.index].arn
  traffic_type    = "ALL"

  tags = merge(
    {
      Name = local.vpc_flow_log_name
      //      TFModule        = local.module_git_url
      TFModuleVersion = local.module_version
      TFModuleName    = local.module_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "flow_logs", {}),
    lookup(local.tags, "flow_log_vpc", {})
  )
}

#tfsec:ignore:AWS089
resource "aws_cloudwatch_log_group" "vpc_log_group" {
  count = var.create_vpc ? 1 : 0

  name              = local.vpc_cloudwatch_log_group_name
  retention_in_days = var.vpc_cloudwatch_log_group_retention

  tags = merge(
    {
      Name = local.vpc_cloudwatch_log_group_name
      //      TFModule        = local.module_git_url
      TFModuleVersion = local.module_version
      TFModuleName    = local.module_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "log_groups", {}),
    lookup(local.tags, "log_group_vpc", {})
  )

}

resource "aws_iam_role" "vpc_flowlogs_role" {
  count = var.create_vpc && var.flowlogs_role_name == "" ? 1 : 0

  name               = local.vpc_flow_log_role_name
  assume_role_policy = file("${path.module}/policies/vpc_flow_logs_assume_role.json")

  tags = merge(
    {
      Name = local.vpc_flow_log_role_name
      //      TFModule        = local.module_git_url
      TFModuleVersion = local.module_version
      TFModuleName    = local.module_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "iam_roles", {}),
    lookup(local.tags, "iam_role_nw_vpc_fw", {})
  )
}


resource "aws_iam_role_policy" "vpc_flowlogs_policy" {
  count = var.create_vpc && var.flowlogs_role_name == "" ? 1 : 0

  name = local.vpc_flow_log_policy_name
  role = aws_iam_role.vpc_flowlogs_role[count.index].id

  policy = file("${path.module}/policies/vpc_flow_logs_policy.json")
}
