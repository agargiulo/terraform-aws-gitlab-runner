variable "prefix" {
  type    = string
  default = "gitlab-runner"
}

variable "ami_release" {
  description = "Debian release name slug"
  type        = string
  default     = "bookworm"
  validation {
    condition     = length(regexall("^[a-z]", var.ami_release)) > 0
    error_message = "The ami_release needs to start with a lower-case letter"
  }
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
    lifecycle = object({
      enabled = bool
      days    = number
    })
  })
}

variable "runner_ec2" {
  type = map(object({
    glr_version = string
    instance = object({
      credit_spec   = string
      role          = string
      type          = string
      ssh_key_pub   = string
      ebs_root_size = number
      swap_size     = number
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

variable "runner_sec_groups" {
  type = map(list(string))
}

variable "runner_subnets" {
  type = map(string)
}

variable "route53_zone_name" {
  description = "Name of the hosted zone for the runners DNS. Empty string disables but caveat, the provider still needs to be set to something"
  type        = string
}
