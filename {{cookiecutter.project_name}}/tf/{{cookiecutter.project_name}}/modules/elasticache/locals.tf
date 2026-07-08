locals {
  provisioned           = { for k, v in var.elasticache_instances : k => v if v.deployment_type == "provisioned" }
  memcached_instances   = { for k, v in local.provisioned : k => v if v.engine == "memcached" }
  replication_instances = { for k, v in local.provisioned : k => v if v.engine != "memcached" }
  serverless_instances  = { for k, v in var.elasticache_instances : k => v if v.deployment_type == "serverless" }
}
