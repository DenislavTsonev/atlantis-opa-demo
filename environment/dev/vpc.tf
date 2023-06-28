module "vpc" {

  source = "../../modules/hc-module-vpc/terraform"

  region = "eu-west-1"

  cidr = "10.0.0.0/16"
  private_subnets = {
    a = ["10.0.0.0/23"]
    b = ["10.0.2.0/23"]
  }
  public_subnets = {
    a = ["10.0.20.0/23"]
    b = ["10.0.22.0/23"]
  }

  enable_nat_gateway       = true
  attach_nat_gateway_to_rt = true

  attach_vpc_to_tgw = false
}
