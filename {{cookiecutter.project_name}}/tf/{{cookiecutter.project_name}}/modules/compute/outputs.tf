# modules/compute/outputs.tf
# ──────────────────────────────────────────────
# Security Groups
# ──────────────────────────────────────────────
output "security_groups" {
  value = {
    for k, v in aws_security_group.ec2_security_group : k => {
      id   = v.id
      arn  = v.arn
      name = v.name
    }
  }
}

output "security_group_ids" {
  value = { for k, v in aws_security_group.ec2_security_group : k => v.id }
}

# ──────────────────────────────────────────────
# EC2 Instances
# ──────────────────────────────────────────────
output "instances" {
  value = {
    for k, v in aws_instance.ec2_instance : k => {
      id                = v.id
      arn               = v.arn
      private_ip        = v.private_ip
      public_ip         = v.public_ip
      subnet_id         = v.subnet_id
      instance_type     = v.instance_type
      availability_zone = v.availability_zone
      tags              = v.tags
    }
  }
}

output "instance_ids" {
  value = { for k, v in aws_instance.ec2_instance : k => v.id }
}

output "private_ips" {
  value = { for k, v in aws_instance.ec2_instance : k => v.private_ip }
}
# ──────────────────────────────────────────────
# Volumes
# ──────────────────────────────────────────────
output "ebs_volume_ids" {
  value = { for k, v in aws_ebs_volume.additional_volume : k => v.id }
}

output "ebs_volume_attachments" {
  value = { for k, v in aws_volume_attachment.volume_attachment : k => {
    instance_id = v.instance_id
    volume_id   = v.volume_id
    device_name = v.device_name
  } }
}

# ──────────────────────────────────────────────
# AMIs
# ──────────
output "amis" {
  value = { for k, v in aws_ami_from_instance.this : k => {
    id   = v.id
    arn  = v.arn
    name = v.name
  } }
}
