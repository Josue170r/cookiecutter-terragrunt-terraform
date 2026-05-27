# modules/s3/outputs.tf
output "bucket_ids" {
  value = { for k, v in aws_s3_bucket.main : k => v.id }
}
