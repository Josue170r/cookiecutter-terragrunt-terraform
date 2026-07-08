include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/elasticache"
}

dependency "networking" {
  config_path = "../networking"
}

dependency "compute" {
  config_path = "../compute"
}

locals {
  shared_path = "${get_terragrunt_dir()}/../../../shared/inputs/elasticache"

  # Proyecto ejemplo elasticache
  example_elasticache = read_terragrunt_config("${local.shared_path}/example_elasticache.hcl")

  all_elasticache_config = merge(
    local.example_elasticache.inputs.elasticache_instances
  )
}

inputs = {
  elasticache_instances = {
    for k, ec in local.all_elasticache_config : k => merge(ec, {
      subnet_ids = [
        for subnet in ec.subnet_ids :
          dependency.networking.outputs.subnet_ids[subnet]
      ]

      vpc_security_group_ids = [
        for sg in ec.vpc_security_group_ids :
          dependency.compute.outputs.security_group_ids[sg]
      ]
    })
  }
}