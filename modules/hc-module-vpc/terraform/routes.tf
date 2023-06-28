#################
# Publiс routes #
#################
resource "aws_route_table" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      Name = local.public_route_table_name
      //      TFModule        = local.module_git_url
      TFModuleVersion = local.module_version
      TFModuleName    = local.module_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "route_tables", {}),
    lookup(local.tags, "route_table_public", {})
  )
}

resource "aws_route" "public_internet_gateway" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[count.index].id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "public_tgw" {
  count = var.create_vpc && length(var.destination_cidr_block_to_tgw) > 0 && length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = var.destination_cidr_block_to_tgw
  transit_gateway_id     = var.tgw_id

  timeouts {
    create = "5m"
  }
}

##################################################################
#                     Private routes                             #
# There are as many routing tables as the number of NAT gateways #
##################################################################
resource "aws_route_table" "private" {
  for_each = var.create_vpc && length(var.private_subnets) > 0 ? var.enable_nat_gateway && var.nat_gateway_per_az ? local.private_subnets : local.one_nat_private_subnets : {}

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      Name = local.private_route_table_name
      //      TFModule        = local.module_git_url
      TFModuleVersion = local.module_version
      TFModuleName    = local.module_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "route_tables", {}),
    lookup(local.tags, "route_table_private", {})
  )
}

resource "aws_route" "private_nat_gateway" {
  for_each = var.create_vpc && var.attach_nat_gateway_to_rt && var.enable_nat_gateway ? var.nat_gateway_per_az ? local.private_subnets : local.one_nat_private_subnets : {}

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "private_tgw" {
  for_each = var.create_vpc && var.attach_vpc_to_tgw && ! var.default_route_tgw && length(var.destination_cidr_block_to_tgw) > 0 ? var.enable_nat_gateway && var.nat_gateway_per_az ? local.private_subnets : local.one_nat_private_subnets : {}

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = var.destination_cidr_block_to_tgw
  transit_gateway_id     = var.tgw_id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "private_tgw_default" {
  for_each = var.create_vpc && var.attach_vpc_to_tgw && var.default_route_tgw && ! var.enable_nat_gateway ? local.one_nat_private_subnets : {}

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.tgw_id

  timeouts {
    create = "5m"
  }
}

###################
# Database routes #
###################
resource "aws_route_table" "database" {
  for_each = var.create_vpc && length(var.database_subnets) > 0 ? var.enable_nat_gateway && var.nat_gateway_per_az ? local.database_subnets : local.one_nat_database_subnets : {}

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      Name = local.database_route_table_name
      //      TFModule        = local.module_git_url
      TFModuleVersion = local.module_version
      TFModuleName    = local.module_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "route_tables", {}),
    lookup(local.tags, "route_table_tgw", {})
  )
}

resource "aws_route" "database_nat_gateway" {
  for_each = var.create_vpc && var.attach_nat_gateway_to_rt && var.enable_nat_gateway ? var.nat_gateway_per_az ? local.database_subnets : local.one_nat_database_subnets : {}

  route_table_id         = aws_route_table.database[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "database_tgw" {
  for_each = var.create_vpc && var.attach_vpc_to_tgw && ! var.default_route_tgw && length(var.destination_cidr_block_to_tgw) > 0 ? var.enable_nat_gateway && var.nat_gateway_per_az ? local.database_subnets : local.one_nat_database_subnets : {}

  route_table_id         = aws_route_table.database[each.key].id
  destination_cidr_block = var.destination_cidr_block_to_tgw
  transit_gateway_id     = var.tgw_id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "database_tgw_default" {
  for_each = var.create_vpc && var.attach_vpc_to_tgw && var.default_route_tgw && ! var.enable_nat_gateway ? local.one_nat_database_subnets : {}

  route_table_id         = aws_route_table.database[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.tgw_id

  timeouts {
    create = "5m"
  }
}

###################
# TGW routes #
###################
resource "aws_route_table" "tgw" {
  for_each = var.create_vpc && length(var.tgw_subnets) > 0 ? var.nat_gateway_per_az ? local.tgw_subnets : local.one_nat : {}

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      Name = local.tgw_route_table_name
      //      TFModule        = local.module_git_url
      TFModuleVersion = local.module_version
      TFModuleName    = local.module_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "route_tables", {}),
    lookup(local.tags, "route_table_tgw", {})
  )
}

resource "aws_route" "tgw_nat_gateway" {
  for_each = var.attach_nat_gateway_to_rt && var.create_vpc && var.enable_nat_gateway ? var.nat_gateway_per_az ? local.tgw_subnets : local.one_nat : {}

  route_table_id         = aws_route_table.tgw[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id

  timeouts {
    create = "5m"
  }
}

############################
# Route table associations #
############################
resource "aws_route_table_association" "public" {
  for_each = var.create_vpc && length(var.public_subnets) > 0 ? var.enable_nat_gateway && var.nat_gateway_per_az ? { for subnet in aws_subnet.public : subnet.cidr_block => subnet.availability_zone } : { for subnet in aws_subnet.public : subnet.cidr_block => keys(local.public_subnets)[0] } : {}

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  for_each = var.create_vpc && length(var.private_subnets) > 0 ? var.enable_nat_gateway && var.nat_gateway_per_az ? { for subnet in aws_subnet.private : subnet.cidr_block => subnet.availability_zone } : { for subnet in aws_subnet.private : subnet.cidr_block => keys(local.private_subnets)[0] } : {}

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.value].id
}

resource "aws_route_table_association" "database" {
  for_each = var.create_vpc && length(var.database_subnets) > 0 ? var.enable_nat_gateway && var.nat_gateway_per_az ? { for subnet in aws_subnet.database : subnet.cidr_block => subnet.availability_zone } : { for subnet in aws_subnet.database : subnet.cidr_block => keys(local.database_subnets)[0] } : {}

  subnet_id      = aws_subnet.database[each.key].id
  route_table_id = aws_route_table.database[each.value].id
}


resource "aws_route_table_association" "tgw" {
  for_each = var.create_vpc && length(var.tgw_subnets) > 0 ? var.enable_nat_gateway && var.nat_gateway_per_az ? local.reversed_tgw_subnets : { for subnet, az in local.reversed_tgw_subnets : subnet => keys(local.tgw_subnets) } : {}

  subnet_id      = aws_subnet.tgw[each.key].id
  route_table_id = aws_route_table.tgw[each.value[0]].id
}
