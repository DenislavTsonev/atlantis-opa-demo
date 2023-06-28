terraform {
  backend "s3" {
    encrypt = true
    bucket  = "demo-state-bucket"
    key     = "atlantis/dev/terraform.tfstate"
    region  = "eu-west-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.64.2"
    }
  }
}
