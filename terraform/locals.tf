locals {
  atlantis_repo_config_json = var.atlantis_repo_config_json != null ? var.atlantis_repo_config_json : jsonencode(yamldecode(file("${path.module}/server-atlantis.yaml")))

  command = var.command != null ? var.command : ["server", "--enable-policy-checks"]


  container_definition_environment = [
    {
      name  = "ATLANTIS_ALLOW_REPO_CONFIG"
      value = var.allow_repo_config
    },
    {
      name  = "ATLANTIS_LOG_LEVEL"
      value = var.atlantis_log_level
    },
    {
      name  = "ATLANTIS_PORT"
      value = var.atlantis_port
    },
    {
      name  = "ATLANTIS_ATLANTIS_URL"
      value = local.atlantis_url
    },
    {
      name  = "ATLANTIS_BITBUCKET_USER"
      value = var.atlantis_bitbucket_user
    },
    {
      name  = "ATLANTIS_BITBUCKET_BASE_URL"
      value = var.atlantis_bitbucket_base_url
    },
    {
      name  = "ATLANTIS_REPO_ALLOWLIST"
      value = join(",", var.atlantis_repo_allowlist)
    },
    {
      name  = "ATLANTIS_HIDE_PREV_PLAN_COMMENTS"
      value = var.atlantis_hide_prev_plan_comments
    },
    {
      "name" : "ATLANTIS_REPO_CONFIG_JSON",
      "value" : local.atlantis_repo_config_json,
    },
    {
      name  = "GIT_SSH_COMMAND"
      value = var.git_ssh_command
    },
    {
      name  = "OPA_POLICIES_REPO"
      value = var.opa_policies_repo
    },
    {
      name  = "S3_STORING_PLANS"
      value = "demo-state-bucket"
    },
    {
      name  = "S3_STATE_BUCKET"
      value = "demo-state-bucket"
    }
  ]

  # Secret access tokens
  container_definition_secrets_1 = local.secret_name_key != "" && local.secret_name_value_from != "" ? [
    {
      name      = local.secret_name_key
      valueFrom = local.secret_name_value_from
    },
  ] : []

  container_definition_secrets_2 = [
    {
      name      = "SSH_PRIVATE_KEY"
      valueFrom = var.ssh_private_key
    },
  ]

  # token
  secret_name_key        = "ATLANTIS_BITBUCKET_TOKEN"
  secret_name_value_from = var.atlantis_bitbucket_user_token_ssm_parameter_name

  atlantis_url = "http://${coalesce(
    var.atlantis_fqdn,
    element(concat(aws_route53_record.atlantis.*.fqdn, [""]), 0),
    module.alb.lb_dns_name,
    "_"
  )}"
  atlantis_url_events = "${local.atlantis_url}/events"
}

locals {
  tags = merge(
    var.tags
  )
}
