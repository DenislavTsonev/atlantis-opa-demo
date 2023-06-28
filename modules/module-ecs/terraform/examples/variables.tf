variable "region" {
  type        = string
  description = "AWS Region"
}

variable "create_ecs_cluster" {
  type        = bool
  description = "Enable/Disable ECS cluster creation"
}

variable "name" {
  description = "Name to be used on all the resources as identifier, also the name of the ECS cluster"
  type        = string
}

variable "create_task_definition" {
  type        = bool
  description = "Controls if Task definition should be created"
}

variable "iam_enabled" {
  type        = bool
  description = "Enable/Disable IAM role and policy creation necessary for ECS cluster"
}

variable "security_groups" {
  type = list(string)
  description = "List of security groups"
}

variable "subnet_ids" {
  type = list(string)
  description = "List of subnet IDs"
}

variable "ecs_launch_type" {
  type        = string
  description = "ECS launch type"
}

variable "network_mode" {
  type        = string
  description = "The network mode to use for the task. This is required to be `awsvpc` for `FARGATE` `launch_type`"
}

variable "task_cpu" {
  type        = number
  description = "The number of CPU units used by the task. If using `FARGATE` launch type `task_cpu` must match supported memory values (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size)"
}

variable "task_memory" {
  type        = number
  description = "The amount of memory (in MiB) used by the task. If using Fargate launch type `task_memory` must match supported cpu value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size)"
}

variable "desired_count" {
  type        = number
  description = "The number of instances of the task definition to place and keep running"
}

variable "deployment_controller_type" {
  type        = string
  description = "Type of deployment controller. Valid values are `CODE_DEPLOY` and `ECS`"
}

variable "deployment_maximum_percent" {
  type        = number
  description = "The upper limit of the number of tasks (as a percentage of `desired_count`) that can be running in a service during a deployment"
}

variable "deployment_minimum_healthy_percent" {
  type        = number
  description = "The lower limit (as a percentage of `desired_count`) of the number of tasks that must remain running and healthy in a service during a deployment"
}

variable "assign_public_ip" {
  type        = bool
  description = "Assign a public IP address to the ENI (Fargate launch type only). Valid values are `true` or `false`. Default `false`"
}

variable "propagate_tags" {
  type        = string
  description = "Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are SERVICE and TASK_DEFINITION"
}
