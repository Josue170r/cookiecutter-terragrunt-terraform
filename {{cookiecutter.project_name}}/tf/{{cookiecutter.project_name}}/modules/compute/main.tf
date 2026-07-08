# ──────────────────────────────────────────────
# Security Groups
# ──────────────────────────────────────────────
resource "aws_security_group" "ec2_security_group" {
  for_each    = var.security_groups
  name        = each.key
  description = each.value.description
  vpc_id      = each.value.vpc_id
  tags        = each.value.tags
}

resource "aws_security_group_rule" "ec2_ingress_rule" {
  for_each          = local.ingress_rules
  type              = "ingress"
  security_group_id = aws_security_group.ec2_security_group[each.value.sg_name].id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks = each.value.instance_name != null ? [
    "${aws_instance.ec2_instance[each.value.instance_name].private_ip}/32"
  ] : each.value.cidr_blocks
  description = each.value.description
}

resource "aws_security_group_rule" "ec2_egress_rule" {
  for_each          = local.egress_rules
  type              = "egress"
  security_group_id = aws_security_group.ec2_security_group[each.value.sg_name].id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  description       = each.value.description
}

# ──────────────────────────────────────────────
# EC2 Instances
# ──────────────────────────────────────────────
resource "aws_instance" "ec2_instance" {
  for_each = var.instances

  ami               = each.value.ami
  instance_type     = each.value.instance_type
  subnet_id         = each.value.subnet_id
  availability_zone = each.value.availability_zone

  key_name = each.value.key_name != null ? each.value.key_name.name : null

  private_ip                  = each.value.private_ip
  associate_public_ip_address = each.value.associate_public_ip_address

  disable_api_termination = each.value.disable_api_termination
  disable_api_stop        = each.value.disable_api_stop

  vpc_security_group_ids = [
    for sg_name in each.value.security_group_names :
    aws_security_group.ec2_security_group[sg_name].id
  ]

  ebs_optimized = each.value.ebs_optimized

  root_block_device {
    volume_size           = each.value.root_volume_size
    volume_type           = each.value.root_volume_type
    delete_on_termination = each.value.delete_on_termination
  }

  iam_instance_profile = each.value.iam_instance_profile

  metadata_options {
    http_endpoint = each.value.metadata_options.http_endpoint
    http_tokens   = each.value.metadata_options.http_tokens
  }

  tags = each.value.tags
}

# ──────────────────────────────────────────────
# AMIs
# ──────────────────────────────────────────────

resource "aws_ami_from_instance" "this" {
  for_each = var.amis

  name                    = each.key
  source_instance_id      = aws_instance.ec2_instance[each.value.source_instance_name].id
  snapshot_without_reboot = each.value.snapshot_without_reboot
  tags                    = each.value.tags

  lifecycle {
    ignore_changes = [name]
  }
}

# ──────────────────────────────────────────────
# EBS Volume
# ──────────────────────────────────────────────
resource "aws_ebs_volume" "additional_volume" {
  for_each = local.ebs_flat

  availability_zone = var.instances[each.value.instance_key].availability_zone
  size              = each.value.size
  type              = each.value.type
  iops              = each.value.iops
  throughput        = each.value.throughput
  encrypted         = each.value.encrypted

  tags = merge(
    var.instances[each.value.instance_key].tags,
    { Name = "${each.value.instance_key}-${each.key}" }
  )
}

resource "aws_volume_attachment" "volume_attachment" {
  for_each = local.ebs_flat

  device_name = each.value.device_name
  volume_id   = aws_ebs_volume.additional_volume[each.key].id
  instance_id = aws_instance.ec2_instance[each.value.instance_key].id
}

# ──────────────────────────────────────────────
# Key Pairs
# ──────────────────────────────────────────────
resource "tls_private_key" "ec2_key" {
  for_each  = { for k, v in local.key_pairs_flat : k => v if !v.existing }
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key_pair" {
  for_each   = { for k, v in local.key_pairs_flat : k => v if !v.existing }
  key_name   = each.key
  public_key = tls_private_key.ec2_key[each.key].public_key_openssh
}

resource "aws_ssm_parameter" "ec2_key_private" {
  for_each = { for k, v in local.key_pairs_flat : k => v if !v.existing }

  name  = "/ec2/keypairs/${each.key}/private-key"
  type  = "SecureString"
  value = tls_private_key.ec2_key[each.key].private_key_pem
}
