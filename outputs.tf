output "s3_cache_bucket" {
  value = {
    arn    = var.s3_cache_config.enabled ? aws_s3_bucket.gitlab_runner_s3_cache[0].arn : null
    bucket = var.s3_cache_config.enabled ? aws_s3_bucket.gitlab_runner_s3_cache[0].bucket : null
    region = var.s3_cache_config.enabled ? aws_s3_bucket.gitlab_runner_s3_cache[0].region : null
  }
}
