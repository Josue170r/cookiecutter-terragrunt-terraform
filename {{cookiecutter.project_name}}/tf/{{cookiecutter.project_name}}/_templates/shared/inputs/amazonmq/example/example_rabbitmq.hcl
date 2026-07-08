inputs = {
  mq_brokers = {
    "{{cookiecutter.project_name}}-${local.env}-rabbitmq-single-tf" = {
      engine_version      = "4.2"
      host_instance_type  = "mq.m7g.medium"
      deployment_mode     = "SINGLE_INSTANCE"
      publicly_accessible = local.env == "prod" ? false : true

      subnet_ids             = local.env == "prod" ? ["PRIVATE-SUBNET-1A"] : []
      vpc_security_group_ids = local.env == "prod" ? ["rabbitmq-sg-tf"] : []

      username_env_var = "TF_VAR_MQ_USERNAME"
      password_env_var = "TF_VAR_MQ_PASSWORD"

      tags = {
        "Name"        = "{{cookiecutter.project_name}}-${local.env}-rabbitmq-single-tf"
        "Environment" = local.env
        "Billing"     = "CloudIT"
      }
    }
  }
}

locals {
  env        = get_env("ENVIRONMENT")
  account_id = get_env("AWS_ACCOUNT_ID")
  region     = "{{cookiecutter.aws_region}}"
}