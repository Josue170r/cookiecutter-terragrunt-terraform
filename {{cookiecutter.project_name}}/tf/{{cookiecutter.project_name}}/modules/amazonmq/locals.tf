locals {
  single_instance  = { for k, v in var.mq_brokers : k => v if v.deployment_mode == "SINGLE_INSTANCE" }
  cluster_multi_az = { for k, v in var.mq_brokers : k => v if v.deployment_mode == "CLUSTER_MULTI_AZ" }
}
