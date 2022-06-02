output "s3_cache_bucket" {
  value = {
    arn    = var.s3_cache_config.enabled ? aws_s3_bucket.gitlab_runner_s3_cache["enabled"].arn : null
    bucket = var.s3_cache_config.enabled ? aws_s3_bucket.gitlab_runner_s3_cache["enabled"].bucket : null
    region = var.s3_cache_config.enabled ? aws_s3_bucket.gitlab_runner_s3_cache["enabled"].region : null
  }
}

output "gitlab_runners" {
  value = {
    for run_key, runner in aws_instance.gitlab_runner :
    run_key => {
      ip     = runner.public_ip
      dns    = aws_route53_record.gitlab_runner_A[run_key].name
      run_id = random_pet.runner_id[run_key].id
      tags   = var.runner_ec2[run_key].register.default_tags
    }
  }
}
