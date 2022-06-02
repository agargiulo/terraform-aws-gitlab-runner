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
    sse_enabled = bool
  })
}

variable "runner_ec2" {
  type = map(object({
    glr_version = string
    instance = object({
      credit_spec     = string
      role            = string
      type            = string
      security_groups = list(string)
      ssh_key_pub     = string
      subnet_id       = string
      ebs_root_size   = number
      swap_size       = number
    })
    s3_cache = object({
      enabled = bool
      prefix  = string
      shared  = bool
    })
    register = object({
      gitlab_host          = string
      ci_token             = string
      default_docker_image = string
      default_tags         = string
      locked               = bool
      run_untagged         = bool
    })
    config = object({
      concurrency = number
      check_intvl = number
    })
  }))
}

variable "route53_zone_name" {
  description = "Name of the hosted zone for the runners DNS. Empty string disables but caveat, the provider still needs to be set to something"
  type        = string
}
