variable "mq_brokers" {
  type = map(object({
    engine_version     = string
    host_instance_type = string
    deployment_mode    = optional(string, "SINGLE_INSTANCE") # "SINGLE_INSTANCE" | "CLUSTER_MULTI_AZ"

    subnet_ids             = optional(list(string), [])
    vpc_security_group_ids = optional(list(string), [])

    username_env_var = string
    password_env_var = string

    publicly_accessible        = optional(bool, false)
    auto_minor_version_upgrade = optional(bool, true)
    apply_immediately          = optional(bool, true)

    logs_general = optional(bool, true)

    maintenance_window = optional(object({
      day_of_week = optional(string, "SUNDAY")
      time_of_day = optional(string, "03:00")
      time_zone   = optional(string, "UTC")
    }), {})

    import_id = optional(string, null)
    tags      = optional(map(string), {})
  }))
  default = {}
}

variable "mq_users" {
  type = map(object({
    username = string
    password = string
  }))
  sensitive = true
  default   = {}
}
