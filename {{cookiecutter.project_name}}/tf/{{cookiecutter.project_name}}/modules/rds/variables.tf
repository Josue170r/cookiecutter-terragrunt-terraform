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
    port     = optional(number, null)

    multi_az               = optional(bool, false)
    subnet_ids             = list(string)
    vpc_security_group_ids = list(string)

    backup_retention_period = optional(number, 7)
    backup_window           = optional(string)
    maintenance_window      = optional(string)

    skip_final_snapshot = optional(bool, false)
    deletion_protection = optional(bool, true)
    publicly_accessible = optional(bool, false)
    snapshot_identifier = optional(string, null)

    import_id = optional(string, null)
    tags      = optional(map(string), {})
  }))
  default = {}
}

variable "db_passwords" {
  type      = map(string)
  sensitive = true
  default   = {}
}
