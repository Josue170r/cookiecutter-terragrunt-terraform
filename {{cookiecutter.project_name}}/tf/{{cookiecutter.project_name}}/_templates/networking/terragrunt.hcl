include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/networking"
}

locals {
  shared_path = "${get_repo_root()}/tf/{{cookiecutter.project_name}}/shared/inputs/networking"

  example_vpc = read_terragrunt_config("${local.shared_path}/example/vpc_inputs.hcl")

  all_vpcs = merge(
    local.example_vpc.inputs.vpcs,
  )
}

inputs = {
  vpcs = local.all_vpcs
}