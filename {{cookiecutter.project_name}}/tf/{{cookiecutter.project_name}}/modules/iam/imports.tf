import {
  for_each = { for k, v in var.iam_roles : k => v.import_id if v.import_id != null }
  to       = aws_iam_role.main[each.key]
  id       = each.value
}

import {
  for_each = { for k, v in var.iam_policies : k => v.import_id if v.import_id != null }
  to       = aws_iam_policy.main[each.key]
  id       = each.value
}
