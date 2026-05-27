output "db_instance_ids" {
  value = merge(
    { for k, v in aws_db_instance.main : k => v.id },
    { for k, v in aws_rds_cluster.main : k => v.id }
  )
}

output "db_endpoints" {
  value = merge(
    { for k, v in aws_db_instance.main : k => v.endpoint },
    { for k, v in aws_rds_cluster.main : k => v.endpoint }
  )
}
