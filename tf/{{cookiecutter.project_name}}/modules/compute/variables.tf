variable "security_groups" {
  type = map(object({
    description = string
    vpc_id      = string
    import_id   = optional(string, null)
    tags        = optional(map(string), {})
    ingress = optional(map(object({
      from_port     = number
      to_port       = number
      protocol      = string
      cidr_blocks   = optional(list(string), [])
      instance_name = optional(string, null)
      description   = optional(string, "")
    })), {})
    egress = optional(map(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = optional(list(string), ["0.0.0.0/0"])
      description = optional(string, "")
    })), {})
  }))
}

variable "instances" {
  type = map(object({
    ami               = optional(string, null)
    ami_name          = optional(string, null)
    instance_type     = string
    subnet_id         = string
    availability_zone = string

    key_name = optional(object({
      name     = optional(string, null)
      existing = bool
    }), null)

    import_id = optional(string, null)

    private_ip                  = optional(string, null)
    associate_public_ip_address = optional(bool, null)
    security_group_names        = list(string)

    ebs_optimized         = optional(bool, true)
    delete_on_termination = optional(bool, false)
    root_volume_size      = optional(number, 20)
    root_volume_type      = optional(string, "gp3")
    disable_api_stop      = optional(bool, false)

    iam_instance_profile = optional(string, null)

    ebs_volumes = optional(map(object({
      size                  = number
      type                  = optional(string, "gp3")
      iops                  = optional(number, null)
      throughput            = optional(number, null)
      encrypted             = optional(bool, true)
      delete_on_termination = optional(bool, false)
      device_name           = string
    })), {})

    tags = optional(map(string), {})
  }))
}

variable "amis" {
  type = map(object({
    source_instance_name    = string
    snapshot_without_reboot = optional(bool, false)
    tags                    = optional(map(string), {})
  }))
  default = {}
}

variable "key_pairs" {
  type = map(object({
    existing = optional(bool, false)
    tags     = optional(map(string), {})
  }))
  default = {}
}
