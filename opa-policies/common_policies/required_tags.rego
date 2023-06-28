package required_tags

# Enforces a set of required tag keys. Values are bot checked
import input as tfplan

required_tags = [
  "owner", 
  "project",
  "environment"
]

# Whitelist the resources which don't have tags as a parameter

resource_whitelist = [
  "aws_iam_role_policy",
  "aws_route_table_association",
  "aws_route",
  "aws_s3_bucket_public_access_block",
  "aws_s3_bucket_policy",
  "aws_iam_role_policy_attachment",
  "aws_security_group_rule",
  "null_resource",
  "aws_lambda_permission",
  "aws_lb_target_group_attachment",
  "aws_ecr_repository_policy",
  "aws_ecr_lifecycle_policy",
  "aws_efs_file_system_policy",
  "aws_efs_mount_target"
]

array_contains(arr, elem) {
  arr[_] = elem
}

evaluated_resources[r] {
    r := tfplan.resource_changes[_]
    not array_contains(resource_whitelist, r.type)
}

get_basename(path) = basename{
    arr := split(path, "/")
    basename:= arr[count(arr)-1]
}


get_tags(resource) =  tags {
    tags := resource.change.after.tags
} else = empty {
    empty := {}
}

deny[reason] {
    resource := evaluated_resources[_]
    action := resource.change.actions[count(resource.change.actions) - 1]
    array_contains(["create", "update"], action)
    tags := get_tags(resource)
    # creates an array of the existing tag keys
    existing_tags := [ key | tags[key] ]
    required_tag := required_tags[_]
    not array_contains(existing_tags, required_tag)

    reason := sprintf(
        "%s: missing required tag %q",
        [resource.address, required_tag]
    )
}
