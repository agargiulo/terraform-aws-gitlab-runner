variable "prefix" {
  type    = string
  default = "gitlab-runner"
}

variable "ami_owner" {
  type    = string
  default = "self"
}

variable "s3_cache_config" {
  description = "Enable and configure the region for using s3 as a runner cache"
  type = object({
    enabled = bool
    region  = string
    logging = object({
      enabled = bool
      bucket  = string
    })
  })
}

variable "runner_ec2" {
  type = map(object({
    ami_slug        = string
    credit_spec     = string
    instance_role   = string
    instance_type   = string
    security_groups = list(string)
    ssh_key_pub     = string
    subnet_id       = string
    ebs_root_size   = number
    s3_cache = object({
      enabled = bool
      prefix  = string
      shared  = bool
    })
    register = object({
      gitlab_host          = string
      tld                  = string
      ci_token             = string
      default_docker_image = string
      default_tags         = string
      locked               = bool
      run_untagged         = bool
      runner_concurrency   = number
    })
  }))
}
