###################
# ALB
###################
module "alb" {
  source  = "../modules/module-elb/terraform/"
  
  name     = var.name
  internal = var.internal

  vpc_id          = var.vpc_id
  subnets         = var.public_subnet_ids
  security_groups = flatten([module.alb_https_sg.security_group_id, module.alb_http_sg.security_group_id, var.security_group_ids])

  access_logs = {
    enabled = var.alb_logging_enabled
    bucket  = var.alb_log_bucket_name
    prefix  = var.alb_log_location_prefix
  }

  enable_deletion_protection = var.alb_enable_deletion_protection

  drop_invalid_header_fields = var.alb_drop_invalid_header_fields

  listener_ssl_policy_default = var.alb_listener_ssl_policy_default
  #https_listeners = [
  #  {
  #    target_group_index   = 0
  #    port                 = 443
  #    protocol             = "HTTPS"
  #    certificate_arn      = var.certificate_arn == "" ? module.acm.this_acm_certificate_arn : var.certificate_arn
  #    action_type          = local.alb_authenication_method
  #    authenticate_oidc    = var.alb_authenticate_oidc
  #    authenticate_cognito = var.alb_authenticate_cognito
  #  },
  #]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "forward"
      #redirect = {
      #  port        = 443
      #  protocol    = "HTTPS"
      #  status_code = "HTTP_301"
      #}
    },
  ]

  target_groups = [
    {
      name                 = var.name
      backend_protocol     = "HTTP"
      backend_port         = var.atlantis_port
      target_type          = "ip"
      deregistration_delay = 10
    },
  ]

  tags = merge(
    {
      Name = var.name
    },
  local.tags)
}

# Forward action for certain CIDR blocks to bypass authentication (eg. GitHub webhooks)
resource "aws_lb_listener_rule" "unauthenticated_access_for_cidr_blocks" {
  count = var.allow_unauthenticated_access ? 1 : 0

  listener_arn = module.alb.https_listener_arns[0]
  priority     = var.allow_unauthenticated_access_priority

  action {
    type             = "forward"
    target_group_arn = module.alb.target_group_arns[0]
  }

  condition {
    source_ip {
      values = var.whitelist_unauthenticated_cidr_blocks
    }
  }

  tags = merge(
    {
      Name = var.name
    },
    local.tags
  )
}

###################
# Security groups
###################
module "alb_https_sg" {
  source  = "../modules/module-sg/terraform/"
  
  create = true

  security_group_name = join("-", [var.name, "alb-https"])
  vpc_id              = var.vpc_id
  description         = "Security group with HTTPS ports open for specific IPv4 CIDR block (or everybody), egress ports are all world open"

  ingress_cidr_blocks = sort(var.alb_ingress_cidr_blocks)

  egress_rules = ["all-all"]

  tags = local.tags
}

module "alb_http_sg" {
  source  = "../modules/module-sg/terraform/"
  
  create = true

  security_group_name = join("-", [var.name, "alb-http"])
  vpc_id              = var.vpc_id
  description         = "Security group with HTTP ports open for specific IPv4 CIDR block (or everybody), egress ports are all world open"

  ingress_cidr_blocks = sort(var.alb_ingress_cidr_blocks)
  ingress_rules       = ["all-all"]

  egress_rules = ["all-all"]

  tags = local.tags
}

module "atlantis_sg" {
  source  = "../modules/module-sg/terraform/"
  
  create = true

  security_group_name = join("-", [var.name, "atlantis"])
  vpc_id              = var.vpc_id
  description         = "Security group with open port for Atlantis (${var.atlantis_port}) from ALB, egress ports are all world open"

  ingress_with_source_security_group_id = [
    {
      from_port                = var.atlantis_port
      to_port                  = var.atlantis_port
      protocol                 = "tcp"
      description              = "Atlantis"
      source_security_group_id = module.alb_https_sg.security_group_id
    },
  ]

  egress_rules = ["all-all"]

  tags = local.tags
}

module "container_definition" {
  source  = "../modules/module-container-definition/terraform/"
  
  container_name  = var.name
  container_image = "${var.atlantis_image}:${var.atlantis_version}"

  container_cpu                = var.container_cpu != null ? var.container_cpu : var.ecs_task_cpu
  container_memory             = var.container_memory != null ? var.container_memory : var.ecs_task_memory
  container_memory_reservation = var.container_memory_reservation

  user                     = var.user
  ulimits                  = var.ulimits
  entrypoint               = var.entrypoint
  command                  = local.command
  working_directory        = var.working_directory
  repository_credentials   = var.repository_credentials
  docker_labels            = var.docker_labels
  start_timeout            = var.start_timeout
  stop_timeout             = var.stop_timeout
  container_depends_on     = var.container_depends_on
  essential                = var.essential
  readonly_root_filesystem = var.readonly_root_filesystem


  mount_points = var.mount_points

  volumes_from = var.volumes_from

  port_mappings = [
    {
      containerPort = var.atlantis_port
      hostPort      = var.atlantis_port
      protocol      = "tcp"
    },
  ]

  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-region        = data.aws_region.current.name
      awslogs-group         = aws_cloudwatch_log_group.atlantis.name
      awslogs-stream-prefix = "ecs"
    }
    secretOptions = []
  }
  firelens_configuration = var.firelens_configuration

  environment = concat(
    local.container_definition_environment,
    var.custom_environment_variables,
  )

  secrets = concat(
    local.container_definition_secrets_1,
    local.container_definition_secrets_2,
    var.custom_environment_secrets,
  )
}


####################
## ECS
####################
module "ecs" {
  source  = "../modules/module-ecs/terraform/"
  
  name                 = var.name
  task_role_name       = join("-", [var.name, "ecs-task"])
  service_role_name    = join("-", [var.name, "ecs-service"])
  exec_role_name       = join("-", [var.name, "ecs-task-exec"])
  service_policy_name  = join("-", [var.name, "ecs-service"])
  ssm_exec_policy_name = join("-", [var.name, "ecs-ssm-exec"])
  exec_policy_name     = join("-", [var.name, "ecs-task-exec"])

  create_ecs_cluster     = var.create_ecs_cluster
  create_task_definition = var.create_task_definition
  ecs_service_enabled    = var.ecs_service_enabled
  iam_enabled            = var.iam_enabled

  launch_type                        = var.ecs_launch_type
  security_groups                    = [module.atlantis_sg.security_group_id]
  subnet_ids                         = var.private_subnet_ids
  network_mode                       = var.network_mode
  assign_public_ip                   = var.ecs_service_assign_public_ip
  propagate_tags                     = var.propagate_tags
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_controller_type         = var.deployment_controller_type
  desired_count                      = var.ecs_service_desired_count
  task_memory                        = var.ecs_task_memory
  task_cpu                           = var.ecs_task_cpu
  task_family                        = var.name

  container_insights = var.ecs_container_insights
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider_strategy = [{
    capacity_provider = var.ecs_fargate_spot ? "FARGATE_SPOT" : "FARGATE"
  }]

  container_definition_json = module.container_definition.json_map_encoded_list

  ecs_load_balancers = [
    {
      elb_name         = null
      container_name   = var.name
      container_port   = var.atlantis_port
      target_group_arn = element(module.alb.target_group_arns, 0)
    }
  ]

  volumes = []

  tags = merge(
    {
      Name = join("-", [var.name, "cluster"])
    },
    local.tags
  )
}

###################
# Route53 record
###################
resource "aws_route53_record" "atlantis" {
  count = var.create_route53_record ? 1 : 0

  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = var.route53_record_name != null ? var.route53_record_name : var.name
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}

###################
# Cloudwatch logs
###################
resource "aws_cloudwatch_log_group" "atlantis" {
  name              = join("-", [var.name, "cwlg"])
  retention_in_days = var.cloudwatch_log_retention_in_days

  tags = local.tags
}

#########################################################
# Additional policies for ECS task (Atlantis container) #
#########################################################
resource "aws_iam_role_policy" "ecs_task_additional" {
  name = join("-", [var.name, "ecs-tast-policy"])
  role = module.ecs.ecs_task_role_name
  policy = file("${path.module}/policies/atlantis_ecs_task.json")
}
