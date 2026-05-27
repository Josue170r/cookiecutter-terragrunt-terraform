output "lb_arns" {
  value = { for k, v in aws_lb.main : k => v.arn }
}

output "lb_dns_names" {
  value = { for k, v in aws_lb.main : k => v.dns_name }
}

output "lb_zone_ids" {
  value = { for k, v in aws_lb.main : k => v.zone_id }
}

output "target_group_arns" {
  value = { for k, v in aws_lb_target_group.main : k => v.arn }
}

output "listener_arns" {
  value = { for k, v in aws_lb_listener.main : k => v.arn }
}
