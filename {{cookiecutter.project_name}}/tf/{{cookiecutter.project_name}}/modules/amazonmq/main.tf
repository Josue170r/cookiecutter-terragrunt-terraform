resource "aws_mq_broker" "single" {
  for_each = local.single_instance

  broker_name        = each.key
  engine_type        = "RabbitMQ"
  engine_version     = each.value.engine_version
  host_instance_type = each.value.host_instance_type
  deployment_mode    = "SINGLE_INSTANCE"
  storage_type       = "ebs"

  subnet_ids      = each.value.publicly_accessible || length(each.value.subnet_ids) == 0 ? null : [each.value.subnet_ids[0]]
  security_groups = each.value.publicly_accessible || length(each.value.vpc_security_group_ids) == 0 ? null : each.value.vpc_security_group_ids

  publicly_accessible        = each.value.publicly_accessible
  auto_minor_version_upgrade = each.value.auto_minor_version_upgrade
  apply_immediately          = each.value.apply_immediately

  user {
    username = var.mq_users[each.key].username
    password = var.mq_users[each.key].password
  }

  logs {
    general = each.value.logs_general
  }

  maintenance_window_start_time {
    day_of_week = each.value.maintenance_window.day_of_week
    time_of_day = each.value.maintenance_window.time_of_day
    time_zone   = each.value.maintenance_window.time_zone
  }

  tags = each.value.tags
}

resource "aws_mq_broker" "cluster" {
  for_each = local.cluster_multi_az

  broker_name        = each.key
  engine_type        = "RabbitMQ"
  engine_version     = each.value.engine_version
  host_instance_type = each.value.host_instance_type
  deployment_mode    = "CLUSTER_MULTI_AZ"
  storage_type       = "ebs"

  subnet_ids      = each.value.publicly_accessible ? null : each.value.subnet_ids
  security_groups = each.value.publicly_accessible ? null : each.value.vpc_security_group_ids

  publicly_accessible        = each.value.publicly_accessible
  auto_minor_version_upgrade = each.value.auto_minor_version_upgrade
  apply_immediately          = each.value.apply_immediately

  user {
    username = var.mq_users[each.key].username
    password = var.mq_users[each.key].password
  }

  logs {
    general = each.value.logs_general
  }

  maintenance_window_start_time {
    day_of_week = each.value.maintenance_window.day_of_week
    time_of_day = each.value.maintenance_window.time_of_day
    time_zone   = each.value.maintenance_window.time_zone
  }

  tags = each.value.tags
}
