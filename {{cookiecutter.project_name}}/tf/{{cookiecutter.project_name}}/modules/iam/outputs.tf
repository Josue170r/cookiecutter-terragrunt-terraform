output "role_arns" {
  value = { for k, v in aws_iam_role.main : k => v.arn }
}

output "role_names" {
  value = { for k, v in aws_iam_role.main : k => v.name }
}

output "policy_arns" {
  value = { for k, v in aws_iam_policy.main : k => v.arn }
}
