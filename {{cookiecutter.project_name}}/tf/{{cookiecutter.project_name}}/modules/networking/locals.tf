locals {
  subnets = merge([
    for vpc_name, vpc in var.vpcs : {
      for subnet_name, subnet in vpc.subnets :
      "${vpc_name}/${subnet_name}" => {
        vpc_name          = vpc_name
        cidr_block        = subnet.cidr_block
        availability_zone = subnet.availability_zone
        import_id         = subnet.import_id
        tags              = subnet.tags
      }
    }
  ]...)

  secondary_cidrs = merge([
    for vpc_name, vpc in var.vpcs : {
      for cidr in vpc.secondary_cidr_blocks :
      "${vpc_name}-${cidr}" => {
        vpc_name   = vpc_name
        cidr_block = cidr
      }
    }
  ]...)

  internet_gateways = merge([
    for vpc_name, vpc in var.vpcs : {
      for igw_name, igw in vpc.internet_gateways :
      "${vpc_name}/${igw_name}" => {
        vpc_name  = vpc_name
        import_id = igw.import_id
        tags      = igw.tags
      }
    }
  ]...)

  nat_gateways = merge([
    for vpc_name, vpc in var.vpcs : {
      for nat_name, nat in vpc.nat_gateways :
      "${vpc_name}/${nat_name}" => {
        vpc_name      = vpc_name
        subnet_id     = "${vpc_name}/${nat.subnet_id}"
        import_id     = nat.import_id
        eip_import_id = nat.eip_import_id
        tags          = nat.tags
      }
    }
  ]...)

  route_tables = merge([
    for vpc_name, vpc in var.vpcs : {
      for rt_name, rt in vpc.route_tables :
      "${vpc_name}/${rt_name}" => {
        vpc_name  = vpc_name
        import_id = rt.import_id
        tags      = rt.tags
        routes = [
          for r in rt.routes : {
            cidr_block     = r.cidr_block
            igw_id         = r.igw_id != null ? "${vpc_name}/${r.igw_id}" : null
            nat_gateway_id = r.nat_gateway_id != null ? "${vpc_name}/${r.nat_gateway_id}" : null
          }
        ]
        subnet_associations = [
          for s in rt.subnet_associations : "${vpc_name}/${s}"
        ]
      }
    }
  ]...)

  managed_route_tables  = { for k, v in local.route_tables : k => v if v.import_id == null }
  imported_route_tables = { for k, v in local.route_tables : k => v if v.import_id != null }

  route_table_associations = {
    for assoc in flatten([
      for rt_name, rt in local.managed_route_tables : [
        for subnet in rt.subnet_associations : {
          key    = "${rt_name}/${subnet}"
          rt     = rt_name
          subnet = subnet
        }
      ]
    ]) : assoc.key => assoc
  }

  vpc_endpoints = merge([
    for vpc_name, vpc in var.vpcs : {
      for ep_name, ep in lookup(vpc, "vpc_endpoints", {}) :
      "${vpc_name}/${ep_name}" => {
        vpc_name = vpc_name
        service  = ep.service
        route_tables = [
          for rt in ep.route_tables : "${vpc_name}/${rt}"
        ]
        tags = ep.tags
      }
    }
  ]...)
}
