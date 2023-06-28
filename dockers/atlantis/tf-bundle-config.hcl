terraform {
  # Version of Terraform to include in the bundle. An exact version number
  # is required.
  version = "0.14.3"
}

## Define which provider plugins are to be included
providers {
  aws      = {
    versions = ["3.64.2"]
  }
  template = {
    versions = ["2.2.0"]
  }
  null     = {
    versions = ["3.1.0"]
  }
  random   = {
    versions = ["3.1.0"]
  }
  local    = {
    versions = ["2.2.2"]
  }
  external = {
    versions = ["2.2.2"]
  }
  archive  = {
    versions = ["2.2.0"]
  }
}
 