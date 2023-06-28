###################
# Internet Gateway
###################
resource "aws_internet_gateway" "this" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      Name = local.internet_gateway_name
      //      TFModule        = local.module_git_url
      TFModuleVersion = local.module_version
      TFModuleName    = local.module_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "internet_gateways", {}),
    lookup(local.tags, "internet_gateway", {})
  )
}

##############
# NAT Gateway
##############

# Workaround for interpolation not being able to "short-circuit" the evaluation of the conditional branch that doesn't end up being used
# Source: https://github.com/hashicorp/terraform/issues/11566#issuecomment-289417805
#
# The logical expression would be
#
#    nat_gateway_ips = var.reuse_nat_ips ? var.external_nat_ip_ids : aws_eip.nat.*.id
#
# but then when count of aws_eip.nat.*.id is zero, this would throw a resource not found error on aws_eip.nat.*.id.
locals {
  nat_gateway_ips = split(",", var.reuse_nat_ips ? join(",", var.external_nat_ip_ids) : join(",", [for nat_id in aws_eip.nat : nat_id.id]))
  one_nat         = length(var.public_subnets) > 0 ? zipmap([keys(local.public_subnets)[0]], [values(local.public_subnets)[0]]) : {}
}

resource "aws_eip" "nat" {
  for_each = var.create_vpc && var.enable_nat_gateway && false == var.reuse_nat_ips ? var.nat_gateway_per_az ? local.public_subnets : local.one_nat : {}

  vpc = true

  tags = merge(
    {
      Name = local.eip_name
      //      TFModule        = local.module_git_url
      TFModuleVersion = local.module_version
      TFModuleName    = local.module_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "aws_eips", {}),
    lookup(local.tags, "aws_eip", {})
  )
}

resource "aws_nat_gateway" "this" {
  for_each = var.create_vpc && var.enable_nat_gateway ? var.nat_gateway_per_az ? local.public_subnets : local.one_nat : {}

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.value[0]].id

  tags = merge(
    {
      Name = local.nat_gateway_name
      //      TFModule        = local.module_git_url
      TFModuleVersion = local.module_version
      TFModuleName    = local.module_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "nat_gateways", {}),
    lookup(local.tags, "nat_gateway", {})
  )

  depends_on = [aws_internet_gateway.this]
}


###################
# TGW Attachment #
###################
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_to_tgw_attachment" {
  count = var.create_vpc && var.attach_vpc_to_tgw ? 1 : 0

  subnet_ids                                      = [for az, data in { for subnet, data in aws_subnet.private : data.availability_zone => data.id... } : data[0]]
  transit_gateway_id                              = var.tgw_id
  vpc_id                                          = aws_vpc.this[0].id
  transit_gateway_default_route_table_association = var.tgw_default_route_table_association
  transit_gateway_default_route_table_propagation = var.tgw_default_route_table_propagation

  tags = merge(
    {
      Name = local.vpc_to_tgw_attachment_name
      //      TFModule        = local.module_git_url
      TFModuleVersion = local.module_version
      TFModuleName    = local.module_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "vpc_to_tgw_attachments", {}),
    lookup(local.tags, "vpc_to_tgw_attachment", {})
  )
}

resource "aws_ec2_transit_gateway_route_table_association" "rt_association" {
  count    = var.create_vpc && var.attach_vpc_to_tgw ? 1 : 0
  provider = aws.nw

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_to_tgw_attachment[0].id
  transit_gateway_route_table_id = var.tgw_association_rt_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment_accepter.tgw_accepter]
}

resource "aws_ec2_transit_gateway_route_table_propagation" "rt_propagation" {
  count    = var.create_vpc && var.attach_vpc_to_tgw ? length(var.tgw_propagation_rt_id) : 0
  provider = aws.nw

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_to_tgw_attachment[0].id
  transit_gateway_route_table_id = var.tgw_propagation_rt_id[count.index]

  depends_on = [aws_ec2_transit_gateway_vpc_attachment_accepter.tgw_accepter]
}


resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "tgw_accepter" {
  count    = var.create_vpc && var.attach_vpc_to_tgw && local.tgw_auto_accept == "disable" && var.tgw_cross_account_attachment == true ? 1 : 0
  provider = aws.nw

  transit_gateway_attachment_id                   = aws_ec2_transit_gateway_vpc_attachment.vpc_to_tgw_attachment[0].id
  transit_gateway_default_route_table_association = var.tgw_default_route_table_association
  transit_gateway_default_route_table_propagation = var.tgw_default_route_table_propagation

  tags = merge(
    {
      Name = local.tgw_accepter
      //      TFModule        = local.module_git_url
      TFModuleVersion = local.module_version
      TFModuleName    = local.module_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "tgw_accepters", {}),
    lookup(local.tags, "tgw_accepter", {})
  )
}
