provider "aws" {
  region = var.region
}

module "ecs_alb_service_task" {
  source                             = "../"

  name = var.name

  container_definition_json = "[${jsonencode(
        {
          cpu                    = 0
          essential              = true
          image                  = "ghcr.io/runatlantis/atlantis:latest"
          mountPoints            = []
          name                   = "atlantis"
          portMappings           = []
          readonlyRootFilesystem = false
          volumesFrom            = []
        })}]"

  create_ecs_cluster        = var.create_ecs_cluster
  create_task_definition    = var.create_task_definition
  iam_enabled               = var.iam_enabled

  launch_type                        = var.ecs_launch_type
  security_groups                    = var.security_groups
  subnet_ids                         = var.subnet_ids
  network_mode                       = var.network_mode
  assign_public_ip                   = var.assign_public_ip
  propagate_tags                     = var.propagate_tags
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_controller_type         = var.deployment_controller_type
  desired_count                      = var.desired_count
  task_memory                        = var.task_memory
  task_cpu                           = var.task_cpu
}
