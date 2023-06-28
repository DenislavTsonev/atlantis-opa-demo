package allowed_oracle_db_types

import input as tfplan

allowed_instances = [
  "db.r5.xlarge.tpc2.mem4x",
  "db.r5.xlarge.tpc2.mem2x",
  "db.r5.large.tpc1.mem2x",
  "db.x1e.xlarge"
]

array_contains(arr, elem) {
  arr[_] = elem
}

databases[d] {
    d := tfplan.resource_changes[_]
    d.type == "aws_db_instance"
    startswith(d.change.after.engine, "oracle")
}


deny[reason] {
    d := databases[_]
    not array_contains(allowed_instances, d.change.after.instance_class)
    reason := sprintf(
        "Instance class %q: is not allowed for Oracle engines.",
        [d.change.after.instance_class]
    )
}