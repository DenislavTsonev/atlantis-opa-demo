
resource "aws_security_group" "default" {
  count = var.create ? 1 : 0

  name        = var.security_group_name
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name            = var.security_group_name
      TFModuleVersion = local.module_version
      TFModuleName    = local.module_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "resolvers", {})
  )
}
############################
##### Ingress SG rules #####
############################
resource "aws_security_group_rule" "ingress_rules" {
  count = var.create && length(var.ingress_rules) > 0 ? length(var.ingress_rules) : 0

  type              = "ingress"
  from_port         = var.rules[var.ingress_rules[count.index]][0]
  to_port           = var.rules[var.ingress_rules[count.index]][1]
  protocol          = var.rules[var.ingress_rules[count.index]][2]
  cidr_blocks       = var.ingress_cidr_blocks
  description       = var.rules[var.ingress_rules[count.index]][3] #tfsec:ignore:AWS018
  security_group_id = aws_security_group.default.0.id
}

# Security group rules with "cidr_blocks", but without "ipv6_cidr_blocks", "source_security_group_id" and "self"
resource "aws_security_group_rule" "ingress_with_cidr_blocks" {
  count = var.create && length(var.ingress_with_cidr_blocks) > 0 ? length(var.ingress_with_cidr_blocks) : 0

  security_group_id = aws_security_group.default.0.id
  type              = "ingress"

  cidr_blocks = split(",", lookup(var.ingress_with_cidr_blocks[count.index], "cidr_blocks", ""))

  from_port   = lookup(var.ingress_with_cidr_blocks[count.index], "from_port", var.rules[lookup(var.ingress_with_cidr_blocks[count.index], "rule", "_")][0])
  to_port     = lookup(var.ingress_with_cidr_blocks[count.index], "to_port", var.rules[lookup(var.ingress_with_cidr_blocks[count.index], "rule", "_")][1])
  protocol    = lookup(var.ingress_with_cidr_blocks[count.index], "protocol", var.rules[lookup(var.ingress_with_cidr_blocks[count.index], "rule", "_")][2])
  description = lookup(var.ingress_with_cidr_blocks[count.index], "description", "Ingress Rule") #tfsec:ignore:AWS018
}

# Security group rules with "source_security_group_id", but without "cidr_blocks" and "self"
resource "aws_security_group_rule" "ingress_with_source_security_group_id" {
  count = var.create && length(var.ingress_with_source_security_group_id) > 0 ? length(var.ingress_with_source_security_group_id) : 0

  security_group_id = aws_security_group.default.0.id
  type              = "ingress"

  source_security_group_id = var.ingress_with_source_security_group_id[count.index]["source_security_group_id"]

  description = lookup(var.ingress_with_source_security_group_id[count.index], "description", "Ingress Rule") #tfsec:ignore:AWS018
  from_port   = lookup(var.ingress_with_source_security_group_id[count.index], "from_port", var.rules[lookup(var.ingress_with_source_security_group_id[count.index], "rule", "_")][0])
  to_port     = lookup(var.ingress_with_source_security_group_id[count.index], "to_port", var.rules[lookup(var.ingress_with_source_security_group_id[count.index], "rule", "_")][1])
  protocol    = lookup(var.ingress_with_source_security_group_id[count.index], "protocol", var.rules[lookup(var.ingress_with_source_security_group_id[count.index], "rule", "_")][2])
}

resource "aws_security_group_rule" "ingress_with_self" {
  count = var.create && length(var.ingress_with_self) > 0 ? length(var.ingress_with_self) : 0

  security_group_id = aws_security_group.default.0.id
  type              = "ingress"

  self = true

  description = lookup(var.ingress_with_self[count.index], "description", "Ingress Rule") #tfsec:ignore:AWS018
  from_port   = lookup(var.ingress_with_self[count.index], "from_port", var.rules[lookup(var.ingress_with_self[count.index], "rule", "_")][0])
  to_port     = lookup(var.ingress_with_self[count.index], "to_port", var.rules[lookup(var.ingress_with_self[count.index], "rule", "_")][1])
  protocol    = lookup(var.ingress_with_self[count.index], "protocol", var.rules[lookup(var.ingress_with_self[count.index], "rule", "_")][2])
}

###########################
##### Egress SG rules #####
###########################
resource "aws_security_group_rule" "egress_rules" {
  count = var.create && length(var.egress_rules) > 0 ? length(var.egress_rules) : 0

  type      = "egress"
  from_port = var.rules[var.egress_rules[count.index]][0]
  to_port   = var.rules[var.egress_rules[count.index]][1]
  protocol  = var.rules[var.egress_rules[count.index]][2]
  #tfsec:ignore:AWS007
  cidr_blocks       = var.egress_cidr_blocks
  description       = var.rules[var.egress_rules[count.index]][3] #tfsec:ignore:AWS018
  security_group_id = aws_security_group.default.0.id
}

# Security group rules with "cidr_blocks", but without "ipv6_cidr_blocks", "source_security_group_id" and "self"
resource "aws_security_group_rule" "egress_with_cidr_blocks" {
  count = var.create && length(var.egress_with_cidr_blocks) > 0 ? length(var.egress_with_cidr_blocks) : 0

  security_group_id = aws_security_group.default.0.id
  type              = "egress"

  cidr_blocks = split(",", lookup(var.egress_with_cidr_blocks[count.index], "cidr_blocks", join(",", var.egress_cidr_blocks)))

  from_port   = lookup(var.egress_with_cidr_blocks[count.index], "from_port", var.rules[lookup(var.egress_with_cidr_blocks[count.index], "rule", "_")][0])
  to_port     = lookup(var.egress_with_cidr_blocks[count.index], "to_port", var.rules[lookup(var.egress_with_cidr_blocks[count.index], "rule", "_")][1])
  protocol    = lookup(var.egress_with_cidr_blocks[count.index], "protocol", var.rules[lookup(var.egress_with_cidr_blocks[count.index], "rule", "_")][2])
  description = lookup(var.egress_with_cidr_blocks[count.index], "description", "Egress Rule") #tfsec:ignore:AWS018
}

# Security group rules with "source_security_group_id", but without "cidr_blocks" and "self"
resource "aws_security_group_rule" "egress_with_source_security_group_id" {
  count = var.create && length(var.egress_with_source_security_group_id) > 0 ? length(var.egress_with_source_security_group_id) : 0

  security_group_id = aws_security_group.default.0.id
  type              = "egress"

  source_security_group_id = var.egress_with_source_security_group_id[count.index]["source_security_group_id"]

  description = lookup(var.egress_with_source_security_group_id[count.index], "description", "Egress Rule") #tfsec:ignore:AWS018
  from_port   = lookup(var.egress_with_source_security_group_id[count.index], "from_port", var.rules[lookup(var.egress_with_source_security_group_id[count.index], "rule", "_")][0])
  to_port     = lookup(var.egress_with_source_security_group_id[count.index], "to_port", var.rules[lookup(var.egress_with_source_security_group_id[count.index], "rule", "_")][1])
  protocol    = lookup(var.egress_with_source_security_group_id[count.index], "protocol", var.rules[lookup(var.egress_with_source_security_group_id[count.index], "rule", "_")][2])
}

# Security group rules with "self", but without "cidr_blocks" and "source_security_group_id"
resource "aws_security_group_rule" "egress_with_self" {
  count = var.create && length(var.egress_with_self) > 0 ? length(var.egress_with_self) : 0

  security_group_id = aws_security_group.default.0.id
  type              = "egress"

  self = true

  description = lookup(var.egress_with_self[count.index], "description", "Egress Rule") #tfsec:ignore:AWS018
  from_port   = lookup(var.egress_with_self[count.index], "from_port", var.rules[lookup(var.egress_with_self[count.index], "rule", "_")][0])
  to_port     = lookup(var.egress_with_self[count.index], "to_port", var.rules[lookup(var.egress_with_self[count.index], "rule", "_")][1])
  protocol    = lookup(var.egress_with_self[count.index], "protocol", var.rules[lookup(var.egress_with_self[count.index], "rule", "_")][2])
}
