# modules/s3/main.tf
resource "aws_s3_bucket" "main" {
  for_each = var.s3_buckets

  bucket        = each.key
  force_destroy = each.value.force_destroy

  tags = each.value.tags
}

resource "aws_s3_bucket_versioning" "main" {
  for_each = var.s3_buckets

  bucket = aws_s3_bucket.main[each.key].id

  versioning_configuration {
    status = each.value.versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  for_each = var.s3_buckets

  bucket = aws_s3_bucket.main[each.key].id

  block_public_acls       = each.value.block_public_acls
  block_public_policy     = each.value.block_public_policy
  ignore_public_acls      = each.value.ignore_public_acls
  restrict_public_buckets = each.value.restrict_public_buckets
}

resource "aws_s3_bucket_policy" "main" {
  for_each = {
    for k, v in var.s3_buckets : k => v if v.policy != null
  }

  bucket = aws_s3_bucket.main[each.key].id
  policy = each.value.policy

  depends_on = [aws_s3_bucket_public_access_block.main]
}

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  for_each = {
    for k, v in var.s3_buckets : k => v if length(v.lifecycle_rules) > 0
  }

  bucket = aws_s3_bucket.main[each.key].id
  dynamic "rule" {
    for_each = each.value.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status
      filter {
        prefix = rule.value.filter.prefix
      }
      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []
        content {
          days                         = expiration.value.days
          expired_object_delete_marker = expiration.value.expired_object_delete_marker
        }
      }
      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration != null ? [rule.value.noncurrent_version_expiration] : []
        content {
          noncurrent_days = noncurrent_version_expiration.value.noncurrent_days
        }
      }
      dynamic "transition" {
        for_each = rule.value.transition
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }
      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transition
        content {
          noncurrent_days = noncurrent_version_transition.value.noncurrent_days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }
}
