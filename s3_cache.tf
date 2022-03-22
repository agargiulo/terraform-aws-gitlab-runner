resource "aws_s3_bucket" "gitlab_runner_s3_cache" {
  for_each = var.s3_cache_config.enabled ? toset(["enabled"]) : toset([])

  bucket = "${var.prefix}-gl-runner-cache"
}
resource "aws_s3_bucket_versioning" "gitlab_runner_s3_cache" {
  for_each = var.s3_cache_config.enabled ? toset(["enabled"]) : toset([])

  bucket = aws_s3_bucket.gitlab_runner_s3_cache[each.value].bucket
  versioning_configuration {
    ## TODO: Change this to Disabled once the old buckets are gone
    status = "Suspended"
  }
}
resource "aws_s3_bucket_logging" "gitlab_runner_s3_cache" {
  for_each = var.s3_cache_config.logging.enabled ? toset(["enabled"]) : toset([])
  bucket   = aws_s3_bucket.gitlab_runner_s3_cache[each.value].bucket

  target_bucket = var.s3_cache_config.logging.bucket
  target_prefix = "${aws_s3_bucket.gitlab_runner_s3_cache[each.value].bucket}/"
}
resource "aws_s3_bucket_server_side_encryption_configuration" "gitlab_runner_s3_cache" {
  for_each = var.s3_cache_config.sse_enabled ? toset(["enabled"]) : toset([])
  bucket   = aws_s3_bucket.gitlab_runner_s3_cache[each.value].bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_public_access_block" "gitlab_runner_s3_cache" {
  for_each = var.s3_cache_config.enabled ? toset(["enabled"]) : toset([])

  bucket                  = aws_s3_bucket.gitlab_runner_s3_cache[each.value].bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
