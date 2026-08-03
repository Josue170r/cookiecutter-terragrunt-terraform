variable "db_instances" {
  type = map(object({
    db_instance_type = optional(string, "instance")

    engine         = string
    engine_version = string
    instance_class = string

    allocated_storage     = optional(number, null)
    max_allocated_storage = optional(number, null)
    storage_type          = optional(string, "gp3")
    storage_encrypted     = optional(bool, true)
    kms_key_id            = optional(string, null)
    iops                  = optional(number)

    db_name  = optional(string, null)
    username = string
    password = optional(string, null)
    port     = optional(number, null)

    manage_master_user_password   = optional(bool, false)
    master_user_secret_kms_key_id = optional(string, null)

    multi_az               = optional(bool, false)
    subnet_ids             = list(string)
    vpc_security_group_ids = list(string)

    deletion_protection        = optional(bool, true)
    auto_minor_version_upgrade = optional(bool, true)

    backup_retention_period = optional(number, 7)
    backup_window           = optional(string, "03:00-04:00")
    maintenance_window      = optional(string, "mon:04:00-mon:05:00")

    skip_final_snapshot = optional(bool, false)
    publicly_accessible = optional(bool, false)
    snapshot_identifier = optional(string, null)

    import_id = optional(string, null)
    tags      = optional(map(string), {})
  }))
  default = {}
}
