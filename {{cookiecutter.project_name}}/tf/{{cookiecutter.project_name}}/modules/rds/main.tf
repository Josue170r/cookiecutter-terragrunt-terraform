resource "aws_db_subnet_group" "main" {
  for_each = var.db_instances

  name       = "${each.key}-subnet-group"
  subnet_ids = each.value.subnet_ids

  tags = merge(each.value.tags, {
    Name = "${each.key}-subnet-group"
  })
}

# ── RDS Single Instance ────────────────────────────────────────────────────────────
resource "aws_db_instance" "main" {
  for_each = local.instances

  identifier     = each.key
  engine         = each.value.engine
  engine_version = each.value.engine_version
  instance_class = each.value.instance_class

  allocated_storage     = each.value.allocated_storage
  max_allocated_storage = each.value.max_allocated_storage
  storage_type          = each.value.storage_type
  storage_encrypted     = each.value.storage_encrypted
  iops                  = each.value.iops

  db_name  = each.value.db_name
  username = each.value.username
  password = var.db_passwords[each.key]
  port     = each.value.port

  multi_az               = each.value.multi_az
  db_subnet_group_name   = aws_db_subnet_group.main[each.key].name
  vpc_security_group_ids = each.value.vpc_security_group_ids

  backup_retention_period = each.value.backup_retention_period
  backup_window           = each.value.backup_window
  maintenance_window      = each.value.maintenance_window

  skip_final_snapshot       = each.value.skip_final_snapshot
  final_snapshot_identifier = each.value.skip_final_snapshot ? null : "${each.key}-final-snapshot"
  deletion_protection       = each.value.deletion_protection
  publicly_accessible       = each.value.publicly_accessible
  snapshot_identifier       = each.value.snapshot_identifier

  tags = each.value.tags
}

# ── Aurora cluster ────────────────────────────────────────────────────────────
resource "aws_rds_cluster" "main" {
  for_each = local.clusters

  cluster_identifier = each.key
  engine             = each.value.engine
  engine_version     = each.value.engine_version

  database_name   = each.value.db_name
  master_username = each.value.username
  master_password = var.db_passwords[each.key]
  port            = each.value.port

  db_subnet_group_name   = aws_db_subnet_group.main[each.key].name
  vpc_security_group_ids = each.value.vpc_security_group_ids

  storage_encrypted = each.value.storage_encrypted
  kms_key_id        = each.value.kms_key_id

  backup_retention_period      = each.value.backup_retention_period
  preferred_backup_window      = each.value.backup_window
  preferred_maintenance_window = each.value.maintenance_window

  skip_final_snapshot       = each.value.skip_final_snapshot
  final_snapshot_identifier = each.value.skip_final_snapshot ? null : "${each.key}-final-snapshot"
  deletion_protection       = each.value.deletion_protection
  snapshot_identifier       = each.value.snapshot_identifier

  tags = each.value.tags
}

resource "aws_rds_cluster_instance" "main" {
  for_each = local.clusters

  identifier         = "${each.key}-instance-1"
  cluster_identifier = aws_rds_cluster.main[each.key].id
  instance_class     = each.value.instance_class
  engine             = each.value.engine
  engine_version     = each.value.engine_version

  db_subnet_group_name = aws_db_subnet_group.main[each.key].name
  publicly_accessible  = each.value.publicly_accessible

  tags = each.value.tags
}
