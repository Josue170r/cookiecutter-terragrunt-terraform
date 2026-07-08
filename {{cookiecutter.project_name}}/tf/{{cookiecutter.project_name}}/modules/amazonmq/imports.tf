import {
  for_each = { for k, v in var.mq_brokers : k => v.import_id if v.import_id != null && v.deployment_mode == "SINGLE_INSTANCE" }
  to       = aws_mq_broker.single[each.key]
  id       = each.value
}

import {
  for_each = { for k, v in var.mq_brokers : k => v.import_id if v.import_id != null && v.deployment_mode == "CLUSTER_MULTI_AZ" }
  to       = aws_mq_broker.cluster[each.key]
  id       = each.value
}
