variable "region" {
  type = string
  default = "eu-west-1"
}

variable "container_memory" {
  type        = number
  description = "The amount of memory (in MiB) to allow the container to use. This is a hard limit, if the container attempts to exceed the container_memory, the container is killed. This field is optional for Fargate launch type and the total amount of container_memory of all containers in a task will need to be lower than the task memory value"
  default     = null
}

variable "container_memory_reservation" {
  type        = number
  description = "The amount of memory (in MiB) to reserve for the container. If container needs to exceed this threshold, it can do so up to the set container_memory hard limit"
  default     = null
}

variable "container_definition" {
  type        = map
  description = "Container definition overrides which allows for extra keys or overriding existing keys."
  default     = {}
}

variable "port_mappings" {
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))

  description = "The port mappings to configure for the container. This is a list of maps. Each map should contain \"containerPort\", \"hostPort\", and \"protocol\", where \"protocol\" is one of \"tcp\" or \"udp\". If using containers in a task with the awsvpc or host network mode, the hostPort can either be left blank or set to the same value as the containerPort"

  default = []
}

variable "container_cpu" {
  type        = number
  description = "The number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of container_cpu of all containers in a task will need to be lower than the task-level cpu value"
  default     = 0
}

variable "essential" {
  type        = bool
  description = "Determines whether all other containers in a task are stopped, if this container fails or stops for any reason. Due to how Terraform type casts booleans in json it is required to double quote this value"
  default     = true
}

variable "container_environment" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "The environment variables to pass to the container. This is a list of maps. map_environment overrides environment"
  default     = []
}

variable "extra_hosts" {
  type = list(object({
    ipAddress = string
    hostname  = string
  }))
  description = "A list of hostnames and IP address mappings to append to the /etc/hosts file on the container. This is a list of maps"
  default     = null
}

variable "readonly_root_filesystem" {
  type        = bool
  description = "Determines whether a container is given read-only access to its root filesystem. Due to how Terraform type casts booleans in json it is required to double quote this value"
  default     = false
}


# https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LogConfiguration.html
variable "log_configuration" {
  type        = any
  description = "Log configuration options to send to a custom log driver for the container. For more details, see https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LogConfiguration.html"
  default     = null
}

variable "privileged" {
  type        = bool
  description = "When this variable is `true`, the container is given elevated privileges on the host container instance (similar to the root user). This parameter is not supported for Windows containers or tasks using the Fargate launch type."
  default     = null
}

variable "hostname" {
  type        = string
  description = "The hostname to use for your container."
  default     = null
}

variable "interactive" {
  type        = bool
  description = "When this parameter is true, this allows you to deploy containerized applications that require stdin or a tty to be allocated."
  default     = null
}

variable "pseudo_terminal" {
  type        = bool
  description = "When this parameter is true, a TTY is allocated. "
  default     = null
}
