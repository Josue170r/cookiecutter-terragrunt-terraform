import {
  for_each = { for k, v in var.db_instances : k => v.import_id if v.import_id != null && v.db_instance_type == "instance" }
  to       = aws_db_instance.main[each.key]
  id       = each.value
}

import {
  for_each = { for k, v in var.db_instances : k => v.import_id if v.import_id != null && v.db_instance_type == "cluster" }
  to       = aws_rds_cluster.main[each.key]
  id       = each.value
}
