variable "create_vpc" {
  description = "Should be false if you want skip VPC creation"
  type        = bool
  default     = true
}

variable "region" {
  description = "The AWS Region"
  type        = string
  default     = ""
}

variable "global_prefix" {
  description = "Global prefix used to construct resource names"
  type        = map(string)
  default = {
    eip              = "default-nat-eip"
    nat_gateway      = "default-nat"
    internet_gateway = "default-igw"
    tgw_attachment   = "default-vpc-tgw-att"
    route_table      = "default-rt"
    subnets          = "default-sub"
    vpc              = "default-vpc"
    dhcp_options     = "default-dhcp-opt"
    cw_loggrp        = "default-vpc-flow-log"
    vpc_flowlogs     = "default-vpc-flow-log"
    iam_role         = "default-vpc-flow-log-iam-role"
    iam_policy       = "default-vpc-flow-log-iam-policy"
    vpn_gateway      = "default-vpn-gw"
    customer_gateway = "default-customer-gw"
    vpn_connection   = "default-vpn-conn"
    tgw_accepter     = "default-tgw-accepter"
  }
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "public_subnets" {
  description = "Map from availability zone to the list of subnets correspoding to that AZ"
  type        = map(list(string))
  default     = {}
}

variable "private_subnets" {
  description = "Map from availability zone to the list of subnets correspoding to that AZ"
  type        = map(list(string))
  default     = {}
}

variable "database_subnets" {
  description = "Map from availability zone to the list of subnets correspoding to that AZ"
  type        = map(list(string))
  default     = {}
}

variable "tgw_subnets" {
  description = "Map from availability zone to the list of subnets correspoding to that AZ"
  type        = map(list(string))
  default     = {}
}

variable "custom_subnets" {
  description = "Map from availability zone to the list of subnets correspoding to that AZ"
  type        = map(map(map(string)))
  default     = {}
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = false
}

variable "nat_gateway_per_az" {
  description = "Should be false if you want only one NAT Gateway"
  type        = bool
  default     = true
}

variable "attach_nat_gateway_to_rt" {
  description = "Should be true if you want to attach the NAT Gateway to the private route table."
  type        = bool
  default     = false
}

variable "reuse_nat_ips" {
  description = "Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external_nat_ip_ids' variable"
  type        = bool
  default     = false
}

variable "external_nat_ip_ids" {
  description = "List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse_nat_ips)"
  type        = list(string)
  default     = []
}

variable "map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(map(string))
  default     = {}
}

variable "vpc_cloudwatch_log_group_retention" {
  description = "VPC flow logs in CloudWatch logGroup retention in days"
  type        = number
  default     = 90
}

variable "flowlogs_role_name" {
  description = "VPC flowlog role name if passed externaly"
  type        = string
  default     = ""
}



# ---------------------------
# DHCP options
variable "enable_dhcp_options" {
  description = "Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type"
  type        = bool
  default     = false
}

variable "dhcp_options_domain_name" {
  description = "Specifies DNS name for DHCP options set (requires enable_dhcp_options set to true)"
  type        = string
  default     = ""
}

variable "dhcp_options_domain_name_servers" {
  description = "Specify a list of DNS server addresses for DHCP options set, default to AWS provided (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = []
}

variable "dhcp_options_ntp_servers" {
  description = "Specify a list of NTP servers for DHCP options set (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_name_servers" {
  description = "Specify a list of netbios servers for DHCP options set (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_node_type" {
  description = "Specify netbios node_type for DHCP options set (requires enable_dhcp_options set to true)"
  type        = string
  default     = ""
}

# ---------------------------
# Transit Gateway
variable "attach_vpc_to_tgw" {
  description = "If we what to attached the VPC to TGW, then the value should be true"
  type        = bool
  default     = false
}

variable "tgw_id" {
  description = "The Transit Gateway ID."
  type        = string
  default     = ""
}

variable "tgw_association_rt_id" {
  description = "The Transit Gateway Route Table to associate with"
  type        = string
  default     = ""
}

variable "tgw_propagation_rt_id" {
  description = "The Transit Gateway Route Tables to propagate."
  type        = list(string)
  default     = []
}

variable "destination_cidr_block_to_tgw" {
  description = "The Destination CIDR Block which will go to the TGW"
  type        = string
  default     = ""
}

variable "default_route_tgw" {
  description = "Private Route Tables default route to Transit Gateway"
  type        = bool
  default     = false
}

variable "tgw_resource" {
  description = "Transit gateway object. Allows overwrite from parent module / different region if needed"
  default     = null
}

variable "tgw_cross_account_attachment" {
  description = "Whether the TGW is in a different account"
  default     = true
}

# ---------------------------
# VPN connection
variable "transit_vpn_connection" {
  description = "Controls if VPN connection should be created"
  type        = bool
  default     = false
}

variable "vpn_type" {
  description = "The type of VPN/CGW. AWS supports only ipsec.1 at this time"
  default     = "ipsec.1"
}

variable "cgw_ip" {
  description = "The external IP address of the customer gateway"
  default     = ""
}

variable "vpn_static_routing" {
  description = "Whether the VPN connection uses static routes or BGP."
  type        = bool
  default     = false
}

variable "vpc_supernet" {
  description = "CIDR of the VPC supernet"
  default     = ""
}

variable "amazon_side_asn" {
  description = "The Autonomous System Number for the Amazon VGW"
  type        = number
  default     = 64513
}

variable "bgp_asn" {
  description = "The Autonomous System Number for the customer's gateway"
  type        = number
  default     = 65000
}

variable "create_vgw" {
  description = "Whether to create a VGW."
  type        = bool
  default     = true
}

variable "vgw_id" {
  description = "The ID of the VGW (in case it's being imported)."
  default     = ""
}

variable "tgw_default_route_table_association" {
  description = "Boolean whether the VPC Attachment should be associated with the EC2 Transit Gateway association default route table."
  default     = true
}

variable "tgw_default_route_table_propagation" {
  description = "Boolean whether the VPC Attachment should propagate routes with the EC2 Transit Gateway propagation default route table"
  default     = true
}