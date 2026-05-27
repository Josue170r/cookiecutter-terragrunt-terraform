import {
  for_each = { for k, v in var.load_balancers : k => v.import_id if v.import_id != null }
  to       = aws_lb.main[each.key]
  id       = each.value
}

import {
  for_each = { for k, v in local.target_groups_flat : k => v.import_id if v.import_id != null }
  to       = aws_lb_target_group.main[each.key]
  id       = each.value
}

import {
  for_each = { for k, v in local.listeners_flat : k => v.import_id if v.import_id != null }
  to       = aws_lb_listener.main[each.key]
  id       = each.value
}
