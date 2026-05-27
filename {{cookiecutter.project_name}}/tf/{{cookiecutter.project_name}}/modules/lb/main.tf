
# ::::: Load Balancer ::::
resource "aws_lb" "main" {
  for_each = var.load_balancers

  name               = each.key
  internal           = each.value.internal
  load_balancer_type = each.value.load_balancer_type
  security_groups    = each.value.security_group_ids
  subnets            = each.value.subnet_ids

  enable_deletion_protection = each.value.enable_deletion_protection
  idle_timeout               = each.value.load_balancer_type == "application" ? each.value.idle_timeout : null
  drop_invalid_header_fields = each.value.load_balancer_type == "application" ? each.value.drop_invalid_header_fields : null

  dynamic "access_logs" {
    for_each = each.value.access_logs_bucket != null ? [1] : []
    content {
      bucket  = each.value.access_logs_bucket
      prefix  = each.value.access_logs_prefix
      enabled = true
    }
  }

  tags = each.value.tags
}

# ::::: Target Groups :::::
resource "aws_lb_target_group" "main" {
  for_each = local.target_groups_flat

  name        = each.key
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = each.value.vpc_id
  target_type = each.value.target_type

  deregistration_delay = each.value.deregistration_delay

  dynamic "health_check" {
    for_each = each.value.health_check != null ? [each.value.health_check] : []
    content {
      enabled             = health_check.value.enabled
      path                = health_check.value.protocol == "TCP" ? null : health_check.value.path
      port                = health_check.value.port
      protocol            = health_check.value.protocol
      healthy_threshold   = health_check.value.healthy_threshold
      unhealthy_threshold = health_check.value.unhealthy_threshold
      timeout             = health_check.value.timeout
      interval            = health_check.value.interval
      matcher             = health_check.value.protocol == "TCP" ? null : health_check.value.matcher
    }
  }

  dynamic "stickiness" {
    for_each = each.value.stickiness != null ? [each.value.stickiness] : []
    content {
      type            = stickiness.value.type
      cookie_duration = stickiness.value.cookie_duration
      enabled         = stickiness.value.enabled
    }
  }

  tags = each.value.tags
}

# ::::: Listeners :::::
resource "aws_lb_listener" "main" {
  for_each = local.listeners_flat

  load_balancer_arn = aws_lb.main[each.value.lb_key].arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = each.value.ssl_policy
  certificate_arn   = each.value.certificate_arn

  default_action {
    type             = each.value.default_action_type
    target_group_arn = each.value.default_action_type == "forward" && each.value.tg_flat_key != null ? aws_lb_target_group.main[each.value.tg_flat_key].arn : null

    dynamic "redirect" {
      for_each = each.value.default_action_type == "redirect" && each.value.redirect != null ? [each.value.redirect] : []
      content {
        port        = redirect.value.port
        protocol    = redirect.value.protocol
        status_code = redirect.value.status_code
      }
    }

    dynamic "fixed_response" {
      for_each = each.value.default_action_type == "fixed-response" && each.value.fixed_response != null ? [each.value.fixed_response] : []
      content {
        content_type = fixed_response.value.content_type
        message_body = fixed_response.value.message_body
        status_code  = fixed_response.value.status_code
      }
    }
  }

  tags = each.value.tags
}

# ::::: Target Group Attachments :::::
resource "aws_lb_target_group_attachment" "main" {
  for_each = local.attachments_flat

  target_group_arn  = aws_lb_target_group.main[each.value.tg_flat_key].arn
  target_id         = each.value.target_id
  port              = each.value.port
  availability_zone = each.value.target_type == "ip" ? each.value.availability_zone : null
}
