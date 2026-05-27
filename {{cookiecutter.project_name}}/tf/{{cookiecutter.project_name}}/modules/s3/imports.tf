# modules/s3/imports.tf
import {
  for_each = { for k, v in var.s3_buckets : k => v.import_id if v.import_id != null }
  to       = aws_s3_bucket.main[each.key]
  id       = each.value
}
