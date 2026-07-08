import {
  for_each = { for k, v in var.elasticache_instances : k => v.import_id if v.import_id != null && v.deployment_type == "provisioned" && v.engine != "memcached" }
  to       = aws_elasticache_replication_group.main[each.key]
  id       = each.value
}

import {
  for_each = { for k, v in var.elasticache_instances : k => v.import_id if v.import_id != null && v.deployment_type == "provisioned" && v.engine == "memcached" }
  to       = aws_elasticache_cluster.memcached[each.key]
  id       = each.value
}

import {
  for_each = { for k, v in var.elasticache_instances : k => v.import_id if v.import_id != null && v.deployment_type == "serverless" }
  to       = aws_elasticache_serverless_cache.main[each.key]
  id       = each.value
}
