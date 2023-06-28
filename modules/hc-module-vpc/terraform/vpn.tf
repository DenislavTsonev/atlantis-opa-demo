###############################
# VPN Connection
###############################
resource "aws_vpn_gateway" "this" {
  count           = var.create_vgw && var.transit_vpn_connection ? 1 : 0
  amazon_side_asn = var.amazon_side_asn

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      Name = local.vpn_gateway_name
      //      TFModule        = local.module_git_url
      TFModuleVersion = local.module_version
      TFModuleName    = local.module_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "vpn_gateways", {}),
    lookup(local.tags, "vpn_gateway_nw_vpc_fw", {})
  )
}

resource "aws_customer_gateway" "this" {
  count = var.transit_vpn_connection ? 1 : 0

  bgp_asn    = var.bgp_asn
  ip_address = var.cgw_ip
  type       = var.vpn_type

  tags = merge(
    {
      Name = local.customer_gateway_name
      //      TFModule        = local.module_git_url
      TFModuleVersion = local.module_version
      TFModuleName    = local.module_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "customer_gateways", {}),
    lookup(local.tags, "customer_gateway_nw_vpc_fw", {})
  )
}

resource "aws_vpn_connection" "this" {
  count = var.transit_vpn_connection ? 1 : 0

  customer_gateway_id = aws_customer_gateway.this[count.index].id
  vpn_gateway_id      = coalesce(var.vgw_id, aws_vpn_gateway.this[count.index].id)
  type                = var.vpn_type
  static_routes_only  = var.vpn_static_routing

  depends_on = [aws_customer_gateway.this, aws_vpn_gateway.this]

  tags = merge(
    {
      Name = local.vpn_connection_name
      //      TFModule        = local.module_git_url
      TFModuleVersion = local.module_version
      TFModuleName    = local.module_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "vpn_connections", {}),
    lookup(local.tags, "vpn_connection_nw_vpc_fw", {})
  )
}

resource "aws_vpn_connection_route" "this" {
  count = var.transit_vpn_connection && var.vpn_static_routing ? 1 : 0

  destination_cidr_block = var.vpc_supernet
  vpn_connection_id      = aws_vpn_connection.this[count.index].id
}

###############################
# Route tables VGW propagation
###############################

# resource "aws_vpn_gateway_route_propagation" "public_rt" {
#   count = var.transit_vpn_connection && length(var.public_subnets) > 0 ? 1 : 0

#   route_table_id = aws_route_table.public[0].id
#   vpn_gateway_id = coalesce(var.vgw_id, aws_vpn_gateway.this[0].id)
# }

# resource "aws_vpn_gateway_route_propagation" "private_rt" {
#   for_each = var.transit_vpn_connection ? var.one_nat_gateway_per_az ? var.private_subnets : local.one_nat : {}

#   route_table_id = aws_route_table.private[each.key].id
#   vpn_gateway_id = coalesce(var.vgw_id, aws_vpn_gateway.this[0].id)
# }

# resource "aws_vpn_gateway_route_propagation" "loadbalancer_rt" {
#   for_each = var.transit_vpn_connection ? var.one_nat_gateway_per_az ? var.loadbalancer_subnets : local.one_nat : {}

#   route_table_id = aws_route_table.loadbalancer[each.key].id
#   vpn_gateway_id = coalesce(var.vgw_id, aws_vpn_gateway.this[0].id)
# }

# resource "aws_vpn_gateway_route_propagation" "middleware_rt" {
#   for_each = var.transit_vpn_connection ? var.one_nat_gateway_per_az ? var.middleware_subnets : local.one_nat : {}

#   route_table_id = aws_route_table.middleware[each.key].id
#   vpn_gateway_id = coalesce(var.vgw_id, aws_vpn_gateway.this[0].id)
# }

# resource "aws_vpn_gateway_route_propagation" "database_rt" {
#   for_each = var.transit_vpn_connection ? var.one_nat_gateway_per_az ? var.database_subnets : local.one_nat : {}

#   route_table_id = aws_route_table.database[each.key].id
#   vpn_gateway_id = coalesce(var.vgw_id, aws_vpn_gateway.this[0].id)
# }

###############################
# Static routes to VGW - you should use either static or propagated routes to VGW due to a know bug - https://forums.aws.amazon.com/thread.jspa?threadID=279390 !!!
###############################

/*
resource "aws_route" "private_vgw" {
  for_each = var.transit_vpn_connection && ! var.attach_nat_gateway_to_rt ? var.one_nat_gateway_per_az ? var.private_subnets : local.one_nat : {}

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = coalesce(var.vgw_id, aws_vpn_gateway.this[0].id)

    depends_on = [aws_vpn_gateway.this]

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "loadbalancer_vgw" {
  for_each = var.transit_vpn_connection && ! var.attach_nat_gateway_to_rt ? var.one_nat_gateway_per_az ? var.loadbalancer_subnets : local.one_nat : {}

  route_table_id         = aws_route_table.loadbalancer[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = coalesce(var.vgw_id, aws_vpn_gateway.this[0].id)

    depends_on = [aws_vpn_gateway.this]

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "middleware_vgw" {
  for_each = var.transit_vpn_connection && ! var.attach_nat_gateway_to_rt ? var.one_nat_gateway_per_az ? var.middleware_subnets : local.one_nat : {}

  route_table_id         = aws_route_table.middleware[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = coalesce(var.vgw_id, aws_vpn_gateway.this[0].id)

    depends_on = [aws_vpn_gateway.this]

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "database_vgw" {
  for_each = var.transit_vpn_connection && ! var.attach_nat_gateway_to_rt ? var.one_nat_gateway_per_az ? var.database_subnets : local.one_nat : {}

  route_table_id         = aws_route_table.database[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = coalesce(var.vgw_id, aws_vpn_gateway.this[0].id)

    depends_on = [aws_vpn_gateway.this]

  timeouts {
    create = "5m"
  }
}
*/
