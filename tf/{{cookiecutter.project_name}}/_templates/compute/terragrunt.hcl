include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/compute"
}

dependency "networking" {
  config_path = "../networking"
}

locals {
  shared_path = "${get_repo_root()}/tf/{{cookiecutter.project_name}}/shared/inputs/compute"

  example_sg  = read_terragrunt_config("${local.shared_path}/example/security_groups_inputs.hcl")
  example_ec2 = read_terragrunt_config("${local.shared_path}/example/ec2_inputs.hcl")

  all_security_groups = merge(
    local.example_sg.inputs.security_groups,
  )

  all_ec2_configs = merge(
    local.example_ec2.inputs.instances,
  )
}

inputs = {
  security_groups = {
    for k, sg in local.all_security_groups : k => merge(sg, {
      vpc_id = dependency.networking.outputs.vpc_ids[sg.vpc_id]
    })
  }

  instances = {
    for k, ec2 in local.all_ec2_configs : k => merge(ec2, {
      subnet_id = dependency.networking.outputs.subnet_ids[ec2.subnet_id]
    })
  }
}