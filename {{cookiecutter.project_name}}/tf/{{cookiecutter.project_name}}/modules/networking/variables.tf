variable "vpcs" {
  type = map(object({
    cidr_block            = string
    import_id             = optional(string, null)
    enable_dns_support    = optional(bool, true)
    enable_dns_hostnames  = optional(bool, true)
    tags                  = optional(map(string), {})
    secondary_cidr_blocks = optional(list(string), [])
    subnets = map(object({
      cidr_block        = string
      availability_zone = string
      import_id         = optional(string, null)
      tags              = optional(map(string), {})
    }))
    internet_gateways = optional(map(object({
      import_id = optional(string, null)
      tags      = optional(map(string), {})
    })), {})
    nat_gateways = optional(map(object({
      subnet_id     = string
      import_id     = optional(string, null)
      eip_import_id = optional(string, null)
      tags          = optional(map(string), {})
    })), {})
    route_tables = optional(map(object({
      import_id = optional(string, null)
      tags      = optional(map(string), {})
      routes = optional(list(object({
        cidr_block     = string
        igw_id         = optional(string, null)
        nat_gateway_id = optional(string, null)
      })), [])
      subnet_associations = optional(list(string), [])
    })), {})
    vpc_endpoints = optional(map(object({
      service      = string
      route_tables = list(string)
      tags         = optional(map(string), {})
    })), {})
  }))
}
