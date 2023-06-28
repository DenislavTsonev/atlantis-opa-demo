locals {
  tags = merge({}, var.tags)
}

locals {
  module_version = chomp(file("${path.module}/../VERSION"))
  module_name    = reverse(split("/", path.module))[1]
}
