module "atlantis" {
  source = "../../terraform"

  region             = "eu-west-1"
  name               = "atlantis"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids

  # Route53
  route53_zone_name   = "democloud.click"
  route53_record_name = "atlantis"

  # Atlantis container
  atlantis_image            = "guevara/atlantis-demo"
  atlantis_version          = "v0.19.3"
  opa_policies_repo         = ""
  atlantis_bitbucket_user   = ""
  atlantis_repo_config_json = jsonencode(yamldecode(file("${path.module}/server-atlantis.yaml")))

  tags = {
    owner       = "project owner"
    project     = "atlantis-demo"
    environment = "dev"
  }
}

