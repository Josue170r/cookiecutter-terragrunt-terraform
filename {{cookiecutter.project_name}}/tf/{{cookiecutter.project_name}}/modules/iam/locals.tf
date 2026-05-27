locals {
  role_inline_policies = merge([
    for role_key, role in var.iam_roles : {
      for policy_key, policy in role.inline_policies :
      "${role_key}/${policy_key}" => {
        role_key = role_key
        policy   = policy.policy
      }
    }
  ]...)

  role_managed_attachments = merge([
    for role_key, role in var.iam_roles : {
      for arn in role.managed_policy_arns :
      "${role_key}/${element(split("/", arn), length(split("/", arn)) - 1)}" => {
        role_key   = role_key
        policy_arn = arn
      }
    }
  ]...)

  role_custom_attachments = merge([
    for role_key, role in var.iam_roles : {
      for policy_key in role.managed_custom_policy_keys :
      "${role_key}/${policy_key}" => {
        role_key   = role_key
        policy_key = policy_key
      }
    }
  ]...)
}
