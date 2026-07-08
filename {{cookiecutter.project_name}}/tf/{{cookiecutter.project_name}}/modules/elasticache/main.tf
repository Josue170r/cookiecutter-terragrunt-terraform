resource "aws_elasticache_subnet_group" "main" {
  for_each = local.provisioned

  name       = "${each.key}-subnet-group"
  subnet_ids = each.value.subnet_ids

  tags = each.value.tags
}

resource "aws_elasticache_replication_group" "main" {
  for_each = local.replication_instances

  replication_group_id = each.key
  description          = "Replication group para ${each.key}"

  engine         = each.value.engine
  engine_version = each.value.engine_version
  node_type      = each.value.node_type
  port           = each.value.port

  subnet_group_name  = aws_elasticache_subnet_group.main[each.key].name
  security_group_ids = each.value.vpc_security_group_ids

  num_node_groups         = each.value.cluster_mode_enabled ? each.value.num_shards : null
  replicas_per_node_group = each.value.cluster_mode_enabled ? each.value.replicas_per_shard : null
  num_cache_clusters      = each.value.cluster_mode_enabled ? null : each.value.replicas_per_shard + 1

  automatic_failover_enabled = each.value.automatic_failover_enabled
  multi_az_enabled           = each.value.multi_az_enabled

  at_rest_encryption_enabled = each.value.at_rest_encryption_enabled
  kms_key_id                 = each.value.kms_key_id
  transit_encryption_enabled = each.value.transit_encryption_enabled
  #   auth_token                   = each.value.auth_token_enabled ? var.elasticache_auth_tokens[each.key] : null

  parameter_group_name     = each.value.parameter_group_name
  snapshot_retention_limit = each.value.snapshot_retention_limit
  snapshot_window          = each.value.snapshot_window
  maintenance_window       = each.value.maintenance_window
  apply_immediately        = each.value.apply_immediately

  tags = each.value.tags
}

resource "aws_elasticache_cluster" "memcached" {
  for_each = local.memcached_instances

  cluster_id     = each.key
  engine         = "memcached"
  engine_version = each.value.engine_version
  node_type      = each.value.node_type
  port           = each.value.port

  num_cache_nodes = each.value.num_cache_nodes
  az_mode         = each.value.num_cache_nodes > 1 ? each.value.az_mode : "single-az"

  subnet_group_name  = aws_elasticache_subnet_group.main[each.key].name
  security_group_ids = each.value.vpc_security_group_ids

  parameter_group_name = each.value.parameter_group_name
  maintenance_window   = each.value.maintenance_window
  apply_immediately    = each.value.apply_immediately

  tags = each.value.tags
}

resource "aws_elasticache_serverless_cache" "main" {
  for_each = local.serverless_instances

  name   = each.key
  engine = each.value.engine

  major_engine_version = each.value.engine_version

  subnet_ids         = each.value.subnet_ids
  security_group_ids = each.value.vpc_security_group_ids

  daily_snapshot_time      = each.value.engine == "memcached" ? null : each.value.daily_snapshot_time
  snapshot_retention_limit = each.value.snapshot_retention_limit
  kms_key_id               = each.value.kms_key_id

  dynamic "cache_usage_limits" {
    for_each = each.value.serverless_max_storage_gb != null || each.value.serverless_max_ecpu_per_second != null ? [1] : []
    content {
      dynamic "data_storage" {
        for_each = each.value.serverless_max_storage_gb != null ? [1] : []
        content {
          maximum = each.value.serverless_max_storage_gb
          unit    = "GB"
        }
      }
      dynamic "ecpu_per_second" {
        for_each = each.value.serverless_max_ecpu_per_second != null ? [1] : []
        content {
          maximum = each.value.serverless_max_ecpu_per_second
        }
      }
    }
  }

  tags = each.value.tags
}
