# ──────────────────────────────────────────────
# Security Groups
# ──────────────────────────────────────────────

import {
  for_each = { for k, v in var.security_groups : k => v.import_id if v.import_id != null }
  to       = aws_security_group.ec2_security_group[each.key]
  id       = each.value
}

# ──────────────────────────────────────────────
# EC2 Instances
# ──────────────────────────────────────────────

import {
  for_each = { for k, v in var.instances : k => v.import_id if v.import_id != null }
  to       = aws_instance.ec2_instance[each.key]
  id       = each.value
}

# ──────────────────────────────────────────────
# EBS
# ──────────────────────────────────────────────

import {
  for_each = {
    for flat_key, vol in local.ebs_flat : flat_key => vol.import_id
    if vol.import_id != null
  }
  to = aws_ebs_volume.additional_volume[each.key]
  id = each.value
}
