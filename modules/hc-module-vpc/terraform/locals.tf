# Prepend region to the AZ
locals {
  public_subnets   = { for az, cidr in var.public_subnets : "${local.region}${az}" => cidr }
  private_subnets  = { for az, cidr in var.private_subnets : "${local.region}${az}" => cidr }
  database_subnets = { for az, cidr in var.database_subnets : "${local.region}${az}" => cidr }
  tgw_subnets      = { for az, cidr in var.tgw_subnets : "${local.region}${az}" => cidr }

  # flatten the custom_subnets, so it can be properly passed
  custom_subnets = length(var.custom_subnets) > 0 ? flatten([
    for network_key, network in var.custom_subnets : [
      for attribute, value in network : [
        for az, cidr in value : {
          network_key = network_key
          az          = "${local.region}${az}"
          cidr_block  = cidr
        }
      ]
    ]
  ]) : []
}


locals {
  reversed_public_subnets   = transpose(local.public_subnets)
  reversed_private_subnets  = transpose(local.private_subnets)
  reversed_database_subnets = transpose(local.database_subnets)
  reversed_tgw_subnets      = transpose(local.tgw_subnets)
}

locals {
  one_nat_private_subnets  = length(var.private_subnets) > 0 ? zipmap([keys(local.private_subnets)[0]], [values(local.private_subnets)[0]]) : {}
  one_nat_database_subnets = length(var.database_subnets) > 0 ? zipmap([keys(local.database_subnets)[0]], [values(local.database_subnets)[0]]) : {}

}

locals {
  module_name    = reverse(split("/", path.module))[1]
  module_version = chomp(file("${path.module}/../VERSION"))
  //  module_git_url = data.external.get_module_git_url.result.git_url
}

locals {
  tags   = merge({}, var.tags)
  region = coalesce(var.region, data.aws_region.current.name)
}

locals {
  vpc_name                   = "${var.global_prefix["vpc"]}-vpc"
  eip_name                   = "${var.global_prefix["eip"]}-vpc"
  public_subnets_name        = "${var.global_prefix["subnets"]}-pub-vpc"
  private_subnets_name       = "${var.global_prefix["subnets"]}-pri-vpc"
  database_subnets_name      = "${var.global_prefix["subnets"]}-db-vpc"
  tgw_subnets_name           = "${var.global_prefix["subnets"]}-tgw-nw-vpc-fw"
  public_route_table_name    = "${var.global_prefix["route_table"]}-pub-vpc"
  private_route_table_name   = "${var.global_prefix["route_table"]}-pri-vpc"
  database_route_table_name  = "${var.global_prefix["route_table"]}-db-vpc"
  tgw_route_table_name       = "${var.global_prefix["route_table"]}-tgw-nw-vpc-fw"
  internet_gateway_name      = "${var.global_prefix["internet_gateway"]}-vpc"
  nat_gateway_name           = "${var.global_prefix["nat_gateway"]}-vpc"
  dhcp_options_name          = "${var.global_prefix["dhcp_options"]}-vpc"
  vpc_to_tgw_attachment_name = "${var.global_prefix["tgw_attachment"]}-vpc"

  vpc_cloudwatch_log_group_name = "${var.global_prefix["vpc_flowlogs"]}-vpc"
  vpc_flow_log_name             = "${var.global_prefix["vpc_flowlogs"]}-vpc"
  vpc_flow_log_role_name        = "${var.global_prefix["iam_role"]}-vpc"
  vpc_flow_log_policy_name      = "${var.global_prefix["iam_policy"]}-vpc"

  vpn_gateway_name      = "${var.global_prefix["vpn_gateway"]}-vpc"
  customer_gateway_name = "${var.global_prefix["customer_gateway"]}-vpc"
  vpn_connection_name   = "${var.global_prefix["vpn_connection"]}-vpc"
  tgw_accepter          = "${var.global_prefix["tgw_accepter"]}-vpc"
}

locals {
  tgw_auto_accept = var.tgw_resource != null ? var.tgw_resource.auto_accept_shared_attachments : try(data.aws_ec2_transit_gateway.networking[0].auto_accept_shared_attachments, "")
}

//locals {
//  tgw_association_rt_id = coalesce(var.tgw_association_rt_id, data.aws_ec2_transit_gateway.networking.association_default_route_table_id)
//  tgw_propagation_rt_id = coalesce(var.tgw_propagation_rt_id, data.aws_ec2_transit_gateway.networking.propagation_default_route_table_id)
//}
