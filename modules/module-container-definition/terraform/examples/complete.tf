provider "aws" {
  region = var.region
}

module "container" {
  source                       = "../"

  container_name               = "atlantis"
  container_image              = "ghcr.io/runatlantis/atlantis:latest"
  container_memory             = var.container_memory
  container_memory_reservation = var.container_memory_reservation
  container_cpu                = var.container_cpu
  essential                    = var.essential
  readonly_root_filesystem     = var.readonly_root_filesystem
  environment                  = var.container_environment
  port_mappings                = var.port_mappings
  log_configuration            = var.log_configuration
  privileged                   = var.privileged
  extra_hosts                  = var.extra_hosts
  hostname                     = var.hostname
  pseudo_terminal              = var.pseudo_terminal
  interactive                  = var.interactive
}


