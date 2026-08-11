generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.0.10"
}

provider "aws" {
  default_tags {
    tags = merge(
      {
        Repo        = "{{cookiecutter.repo_name}}"
        IaC         = "terraform"
        Environment = "${get_env("ENVIRONMENT")}"
      },
      ${get_env("AWS_DEFAULT_REGION") == "mx-central-1" ? "{MEX_REGION = \"mx-central-1\"}" : "{}"}
    )
  }
}
EOF
}

remote_state {
  backend = "s3"
  config = {
    bucket       = "{{cookiecutter.state_bucket}}-${get_env("ENVIRONMENT")}"
    key          = "${path_relative_to_include()}/terraform.tfstate"
    region       = "${get_env("AWS_DEFAULT_REGION")}"
    encrypt      = true
    use_lockfile = true
    profile      = get_env("BACKEND_AWS_PROFILE")
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}