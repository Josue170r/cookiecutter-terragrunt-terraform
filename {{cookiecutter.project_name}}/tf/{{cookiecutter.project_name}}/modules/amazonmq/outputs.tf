output "mq_broker_ids" {
  value = merge(
    { for k, v in aws_mq_broker.single : k => v.id },
    { for k, v in aws_mq_broker.cluster : k => v.id }
  )
}

output "mq_broker_arns" {
  value = merge(
    { for k, v in aws_mq_broker.single : k => v.arn },
    { for k, v in aws_mq_broker.cluster : k => v.arn }
  )
}

output "mq_broker_endpoints" {
  value = merge(
    { for k, v in aws_mq_broker.single : k => v.instances[0].endpoints },
    { for k, v in aws_mq_broker.cluster : k => v.instances[0].endpoints }
  )
}

output "mq_console_urls" {
  value = merge(
    { for k, v in aws_mq_broker.single : k => v.instances[0].console_url },
    { for k, v in aws_mq_broker.cluster : k => v.instances[0].console_url }
  )
}
