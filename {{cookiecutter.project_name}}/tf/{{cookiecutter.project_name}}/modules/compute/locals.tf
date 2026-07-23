locals {
  ingress_rules = merge([
    for sg_name, sg in var.security_groups : {
      for rule_name, rule in sg.ingress :
      "${sg_name}/${rule_name}" => {
        sg_name       = sg_name
        from_port     = rule.from_port
        to_port       = rule.to_port
        protocol      = rule.protocol
        cidr_blocks   = rule.cidr_blocks
        instance_name = rule.instance_name
        description   = rule.description
      }
    }
  ]...)

  egress_rules = merge([
    for sg_name, sg in var.security_groups : {
      for rule_name, rule in sg.egress :
      "${sg_name}/${rule_name}" => {
        sg_name     = sg_name
        from_port   = rule.from_port
        to_port     = rule.to_port
        protocol    = rule.protocol
        cidr_blocks = rule.cidr_blocks
        description = rule.description
      }
    }
  ]...)

  ebs_flat = merge([
    for instance_key, instance in var.instances : {
      for vol_key, vol in instance.ebs_volumes :
      "${vol_key}" => merge(vol, {
        instance_key = instance_key
      })
    }
  ]...)
}
