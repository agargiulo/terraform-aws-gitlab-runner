resource "aws_s3_bucket" "gitlab_runner_s3_cache" {
  count = var.s3_cache_config.enabled ? 1 : 0

  bucket = "${var.prefix}-gl-runner-cache"

  versioning {
    enabled = false
  }

  dynamic "logging" {
    for_each = var.s3_cache_config.logging.enabled ? [var.s3_cache_config.logging.bucket] : []
    content {
      target_bucket = logging.value
      target_prefix = "${var.prefix}-gl-runner-cache/"
    }
  }
}
resource "aws_s3_bucket_public_access_block" "gitlab_runner_s3_cache" {
  count = var.s3_cache_config.enabled ? 1 : 0

  bucket                  = aws_s3_bucket.gitlab_runner_s3_cache[count.index].bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
