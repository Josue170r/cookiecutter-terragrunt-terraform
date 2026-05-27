# modules/s3/variables.tf
variable "s3_buckets" {
  type = map(object({
    versioning              = optional(bool, false)
    force_destroy           = optional(bool, false)
    block_public_acls       = optional(bool, true)
    block_public_policy     = optional(bool, true)
    ignore_public_acls      = optional(bool, true)
    restrict_public_buckets = optional(bool, true)
    policy                  = optional(string, null)
    import_id               = optional(string, null)
    tags                    = optional(map(string), {})

    lifecycle_rules = optional(list(object({
      id     = string
      status = optional(string, "Enabled")

      filter = optional(object({
        prefix = optional(string, "")
      }), {})

      expiration = optional(object({
        days                         = optional(number, null)
        expired_object_delete_marker = optional(bool, null)
      }), null)

      noncurrent_version_expiration = optional(object({
        noncurrent_days = number
      }), null)

      transition = optional(list(object({
        days          = number
        storage_class = string
      })), [])

      noncurrent_version_transition = optional(list(object({
        noncurrent_days = number
        storage_class   = string
      })), [])
    })), [])
  }))
  default = {}
}
