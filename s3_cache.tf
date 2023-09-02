resource "aws_s3_bucket" "gitlab_runner_s3_cache" {
  provider = aws.ci

  for_each = var.s3_cache_config.enabled ? toset(["enabled"]) : toset([])

  bucket = "${var.prefix}-gl-runner-cache"
}
resource "aws_s3_bucket_versioning" "gitlab_runner_s3_cache" {
  provider = aws.ci

  for_each = var.s3_cache_config.enabled ? toset(["enabled"]) : toset([])

  bucket = aws_s3_bucket.gitlab_runner_s3_cache[each.value].bucket
  versioning_configuration {
    status = "Disabled"
  }
  lifecycle {
    # This is so that legacy buckets can keep their "Suspended" state but
    # new buckets should be created without versioning enabled at all.
    ignore_changes = [versioning_configuration]
  }
}
resource "aws_s3_bucket_logging" "gitlab_runner_s3_cache" {
  provider = aws.ci

  for_each = var.s3_cache_config.logging.enabled ? toset(["enabled"]) : toset([])
  bucket   = aws_s3_bucket.gitlab_runner_s3_cache[each.value].bucket

  target_bucket = var.s3_cache_config.logging.bucket
  target_prefix = "${aws_s3_bucket.gitlab_runner_s3_cache[each.value].bucket}/"
}
resource "aws_s3_bucket_server_side_encryption_configuration" "gitlab_runner_s3_cache" {
  provider = aws.ci

  for_each = var.s3_cache_config.sse_enabled ? toset(["enabled"]) : toset([])
  bucket   = aws_s3_bucket.gitlab_runner_s3_cache[each.value].bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_lifecycle_configuration" "gitlab_runner_s3_cache" {
  provider = aws.ci

  for_each = var.s3_cache_config.lifecycle.enabled ? toset(["enabled"]) : toset([])
  bucket   = aws_s3_bucket.gitlab_runner_s3_cache[each.value].bucket
  rule {
    status = "Enabled"
    id     = "delete-older-than-${var.s3_cache_config.lifecycle.days}-days"
    expiration {
      days = var.s3_cache_config.lifecycle.days
    }
  }
}
resource "aws_s3_bucket_public_access_block" "gitlab_runner_s3_cache" {
  provider = aws.ci

  for_each = var.s3_cache_config.enabled ? toset(["enabled"]) : toset([])

  bucket                  = aws_s3_bucket.gitlab_runner_s3_cache[each.value].bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
