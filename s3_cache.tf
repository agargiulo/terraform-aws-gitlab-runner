resource "aws_s3_bucket" "gitlab_runner_s3_cache" {
  count = var.s3_cache_config.enabled ? 1 : 0

  bucket = "${var.prefix}-gl-runner-cache"

  versioning {
    enabled = false
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
