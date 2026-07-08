output "elasticache_endpoints" {
  value = merge(
    { for k, v in aws_elasticache_replication_group.main : k => try(v.configuration_endpoint_address, v.primary_endpoint_address) },
    { for k, v in aws_elasticache_cluster.memcached : k => v.cluster_address },
    { for k, v in aws_elasticache_serverless_cache.main : k => v.endpoint[0].address }
  )
}

output "elasticache_reader_endpoints" {
  value = { for k, v in aws_elasticache_replication_group.main : k => v.reader_endpoint_address if v.reader_endpoint_address != "" }
}

output "elasticache_ids" {
  value = merge(
    { for k, v in aws_elasticache_replication_group.main : k => v.id },
    { for k, v in aws_elasticache_cluster.memcached : k => v.id },
    { for k, v in aws_elasticache_serverless_cache.main : k => v.id }
  )
}
