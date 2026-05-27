variable "load_balancers" {
  type = map(object({
    internal           = optional(bool, false)
    load_balancer_type = optional(string, "application")
    subnet_ids         = list(string)
    security_group_ids = optional(list(string), [])

    enable_deletion_protection = optional(bool, false)
    idle_timeout               = optional(number, 60)
    drop_invalid_header_fields = optional(bool, true)

    access_logs_bucket = optional(string, null)
    access_logs_prefix = optional(string, null)

    import_id = optional(string, null)
    tags      = optional(map(string), {})

    # ::::::: Targer groups ::::::::
    target_groups = optional(map(object({
      port        = number
      protocol    = string
      vpc_id      = string
      target_type = optional(string, "instance")

      deregistration_delay = optional(number, 300)

      health_check = optional(object({
        enabled             = optional(bool, true)
        path                = optional(string, "/")
        port                = optional(string, "traffic-port")
        protocol            = optional(string, "HTTP")
        healthy_threshold   = optional(number, 3)
        unhealthy_threshold = optional(number, 3)
        timeout             = optional(number, 5)
        interval            = optional(number, 30)
        matcher             = optional(string, 200)
      }), null)

      stickiness = optional(object({
        type            = optional(string, "lb_cookie")
        cookie_duration = optional(number, 86400)
        enabled         = optional(bool, true)
      }), null)

      import_id = optional(string, null)
      tags      = optional(map(string), {})

      attachments = optional(map(object({
        target_id         = optional(string, null)
        instance_key      = optional(string, null)
        port              = optional(number, null)
        availability_zone = optional(string, null)
      })), {})
    })), {})

    # ::::::: Listeners ::::::::
    listeners = optional(map(object({
      port             = number
      protocol         = string
      ssl_policy       = optional(string, null)
      certificate_arn  = optional(string, null)
      target_group_key = optional(string, null)

      default_action_type = optional(string, "forward")

      redirect = optional(object({
        port        = optional(string, "443")
        protocol    = optional(string, "HTTPS")
        status_code = optional(string, "HTTP_301")
      }), null)

      fixed_response = optional(object({
        content_type = optional(string, "text/plain")
        message_body = optional(string, "Not Found")
        status_code  = optional(string, "404")
      }), null)

      import_id = optional(string, null)
      tags      = optional(map(string), {})
    })), {})
  }))
  default = {}
}
