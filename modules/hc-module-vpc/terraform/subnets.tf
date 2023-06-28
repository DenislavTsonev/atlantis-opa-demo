#################
# Public subnet #
#################
resource "aws_subnet" "public" {
  for_each = var.create_vpc && length(var.public_subnets) > 0 ? local.reversed_public_subnets : {}

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = each.key
  availability_zone = element(each.value, 0)

  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    {
      Name = "${local.public_subnets_name}-${join("-", slice(split(".", each.key), 0, 3))}"
      //      TFModule        = local.module_git_url
      TFModuleVersion = local.module_version
      TFModuleName    = local.module_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "subnets", {}),
    lookup(local.tags, "subnet_public", {})
  )
}

##################
# Private subnet #
##################
resource "aws_subnet" "private" {
  for_each = var.create_vpc && length(var.private_subnets) > 0 ? local.reversed_private_subnets : {}

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = each.key
  availability_zone = element(each.value, 0)


  tags = merge(
    {
      Name = "${local.private_subnets_name}-${join("-", slice(split(".", each.key), 0, 3))}"
      //      TFModule        = local.module_git_url
      TFModuleVersion = local.module_version
      TFModuleName    = local.module_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "subnets", {}),
    lookup(local.tags, "subnet_private", {})
  )
}

###################
# Database subnet #
###################
resource "aws_subnet" "database" {
  for_each = var.create_vpc && length(var.database_subnets) > 0 ? local.reversed_database_subnets : {}

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = each.key
  availability_zone = element(each.value, 0)


  tags = merge(
    {
      Name = "${local.database_subnets_name}-${join("-", slice(split(".", each.key), 0, 3))}"
      //      TFModule        = local.module_git_url
      TFModuleVersion = local.module_version
      TFModuleName    = local.module_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "subnets", {}),
    lookup(local.tags, "subnet_database", {})
  )
}

###################
# TGW subnet #
###################
resource "aws_subnet" "tgw" {
  for_each = var.create_vpc && length(var.tgw_subnets) > 0 ? local.reversed_tgw_subnets : {}

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = each.key
  availability_zone = element(each.value, 0)


  tags = merge(
    {
      Name = "${local.tgw_subnets_name}-${join("-", slice(split(".", each.key), 0, 3))}"
      //      TFModule        = local.module_git_url
      TFModuleVersion = local.module_version
      TFModuleName    = local.module_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "subnets", {}),
    lookup(local.tags, "subnet_tgw", {})
  )
}

###################
# Custom subnet #
###################
resource "aws_subnet" "custom" {
  for_each = var.create_vpc && length(var.custom_subnets) > 0 ? { for subnet in local.custom_subnets : "${subnet["network_key"]}.${subnet["az"]}" => subnet } : {}

  availability_zone = each.value["az"]
  cidr_block        = each.value["cidr_block"]
  vpc_id            = aws_vpc.this[0].id


  tags = merge(
    {
      Name  = each.key
      Group = each.value["network_key"]
      //      TFModule        = local.module_git_url
      TFModuleVersion = local.module_version
      TFModuleName    = local.module_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "subnets", {}),
    lookup(local.tags, "subnet_${each.key}", {})
  )
}

