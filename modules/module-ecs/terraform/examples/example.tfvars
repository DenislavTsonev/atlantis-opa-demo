region = "eu-west-1"

name = "atlantis"

ecs_launch_type = "FARGATE"

network_mode = "awsvpc"

create_ecs_cluster = true

create_task_definition = true

iam_enabled = true

assign_public_ip = false

propagate_tags = "TASK_DEFINITION"

deployment_minimum_healthy_percent = 100

deployment_maximum_percent = 200

deployment_controller_type = "ECS"

desired_count = 1

task_memory = 512

task_cpu = 256

security_groups = ["sg-d547ed9c"]

subnet_ids = ["subnet-df891c85", "subnet-68d8900e"]

