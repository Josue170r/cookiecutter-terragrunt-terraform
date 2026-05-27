resource "aws_iam_role" "main" {
  for_each = var.iam_roles

  name                 = each.key
  assume_role_policy   = each.value.assume_role_policy
  description          = each.value.description
  path                 = each.value.path
  max_session_duration = each.value.max_session_duration

  tags = each.value.tags
}

resource "aws_iam_role_policy" "main" {
  for_each = local.role_inline_policies

  name   = split("/", each.key)[1]
  role   = aws_iam_role.main[each.value.role_key].id
  policy = each.value.policy
}

resource "aws_iam_role_policy_attachment" "main" {
  for_each = local.role_managed_attachments

  role       = aws_iam_role.main[each.value.role_key].id
  policy_arn = each.value.policy_arn
}

resource "aws_iam_role_policy_attachment" "custom" {
  for_each = local.role_custom_attachments

  role       = aws_iam_role.main[each.value.role_key].id
  policy_arn = aws_iam_policy.main[each.value.policy_key].arn
}

resource "aws_iam_policy" "main" {
  for_each = var.iam_policies

  name        = each.key
  description = each.value.description
  path        = each.value.path
  policy      = each.value.policy

  tags = each.value.tags
}

resource "aws_iam_instance_profile" "main" {
  for_each = {
    for k, v in var.iam_roles : k => v
    if v.create_instance_profile
  }

  name = each.key
  role = aws_iam_role.main[each.key].name
  path = each.value.path

  tags = each.value.tags
}
