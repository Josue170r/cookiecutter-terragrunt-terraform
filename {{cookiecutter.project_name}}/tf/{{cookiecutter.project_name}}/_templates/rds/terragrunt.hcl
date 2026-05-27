include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/rds"
}

dependency "networking" {
  config_path = "../networking"
}

dependency "compute" {
  config_path = "../compute"
}

locals {
  shared_path = "${get_repo_root()}/tf/{{cookiecutter.project_name}}/shared/inputs/rds"

  example_rds = read_terragrunt_config("${local.shared_path}/example/rds_inputs.hcl")

  all_rds_config = merge(
    local.example_rds.inputs.db_instances,
  )
}

inputs = {
  db_instances = {
    for k, db in local.all_rds_config : k => merge(db, {
      subnet_ids = [
        for subnet in db.subnet_ids :
          dependency.networking.outputs.subnet_ids[subnet]
      ]
      vpc_security_group_ids = [
        for sg in db.vpc_security_group_ids :
          dependency.compute.outputs.security_group_ids[sg]
      ]
    })
  }
  db_passwords = {
    for k, db in local.all_rds_config : k => get_env(db.password_env_var)
  }
}