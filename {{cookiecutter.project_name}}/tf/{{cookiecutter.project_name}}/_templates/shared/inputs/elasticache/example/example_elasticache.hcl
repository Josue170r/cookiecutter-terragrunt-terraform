inputs = {
  elasticache_instances = {
    "{{cookiecutter.project_name}}-dev-valkey-tf" = {
      engine               = "valkey"
      engine_version       = "9.0"
      node_type            = "cache.t4g.micro"

      cluster_mode_enabled       = false
      replicas_per_shard         = 0
      automatic_failover_enabled = false
      multi_az_enabled           = false

      subnet_ids = [
        "MAIN-VPC/PRIVATE-SUBNET-1B",
        "MAIN-VPC/PRIVATE-SUBNET-1A"
      ]

      vpc_security_group_ids = [
        "elasticache-sg-tf"
      ]

      at_rest_encryption_enabled = false
      transit_encryption_enabled = false

      tags = {
        "Name"    = "{{cookiecutter.project_name}}-dev-valkey-tf"
        "Billing" = "CloudIT"
      }
    }
  }
}