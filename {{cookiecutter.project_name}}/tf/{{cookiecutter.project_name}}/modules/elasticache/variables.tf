variable "elasticache_instances" {
  type = map(object({
    engine          = string
    engine_version  = string
    deployment_type = optional(string, "provisioned")

    subnet_ids             = list(string)
    vpc_security_group_ids = list(string)
    port                   = optional(number, null)

    node_type = optional(string, null)

    cluster_mode_enabled       = optional(bool, false)
    num_shards                 = optional(number, 1)
    replicas_per_shard         = optional(number, 1)
    automatic_failover_enabled = optional(bool, false)
    multi_az_enabled           = optional(bool, false)
    transit_encryption_enabled = optional(bool, false)
    at_rest_encryption_enabled = optional(bool, false)
    kms_key_id                 = optional(string, null)
    auth_token_enabled         = optional(bool, false)

    num_cache_nodes = optional(number, 1)
    az_mode         = optional(string, "single-az")

    serverless_max_storage_gb      = optional(number, null)
    serverless_max_ecpu_per_second = optional(number, null)
    daily_snapshot_time            = optional(string, null)

    parameter_group_name     = optional(string, null)
    snapshot_retention_limit = optional(number, 0)
    snapshot_window          = optional(string, null)
    maintenance_window       = optional(string, "sun:05:00-sun:07:00")
    apply_immediately        = optional(bool, false)

    import_id = optional(string, null)
    tags      = optional(map(string), {})
  }))
  default = {}
}
