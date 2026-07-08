include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/amazonmq"
}

dependency "networking" {
  config_path = "../networking"
}

dependency "compute" {
  config_path = "../compute"
}

locals {
  shared_path = "${get_terragrunt_dir()}/../../../shared/inputs/amazonmq"

  # Proyecto ejemplo de brokers
  example_brokers = read_terragrunt_config("${local.shared_path}/example_rabbitmq.hcl")

  all_mq_config = merge(
    local.example_brokers.inputs.mq_brokers
  )
}

inputs = {
  mq_brokers = {
    for k, mq in local.all_mq_config : k => merge(mq, {
      subnet_ids = try([
        for subnet in mq.subnet_ids :
          dependency.networking.outputs.subnet_ids[subnet]
      ], [])

      vpc_security_group_ids = try([
        for sg in mq.vpc_security_group_ids :
          dependency.compute.outputs.security_group_ids[sg]
      ], [])
    })
  }

  mq_users = {
    for k, mq in local.all_mq_config : k => {
      username = get_env(mq.username_env_var)
      password = get_env(mq.password_env_var)
    }
  }
}