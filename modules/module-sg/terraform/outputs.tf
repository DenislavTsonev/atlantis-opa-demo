output "security_group_id" {
  description = "The ID of the security group"
  value       = concat(aws_security_group.default.*.id, [""])[0]
}

output "security_group_name" {
  description = "The name of the security group"
  value       = concat(aws_security_group.default.*.name, [""])[0]
}

