variable "iam_roles" {
  type = map(object({
    assume_role_policy      = string
    description             = optional(string, "")
    path                    = optional(string, "/")
    max_session_duration    = optional(number, 3600)
    import_id               = optional(string, null)
    create_instance_profile = optional(bool, false)

    inline_policies = optional(map(object({
      policy = string
    })), {})

    managed_policy_arns        = optional(list(string), [])
    managed_custom_policy_keys = optional(list(string), [])

    tags = optional(map(string), {})
  }))
  default = {}
}

variable "iam_policies" {
  type = map(object({
    description = optional(string, "")
    path        = optional(string, "/")
    policy      = string
    import_id   = optional(string, null)
    tags        = optional(map(string), {})
  }))
  default = {}
}
