variable "prefix" {
  type    = string
  default = "gitlab-runner"
}

variable "ami_owner" {
  type    = string
  default = "self"
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
  default = {
    main = {
      ami_slug        = "main"
      credit_spec     = "standard"
      instance_role   = "terraform_runner"
      instance_type   = "t3a.nano"
      security_groups = []
      ssh_key_pub     = ""
      subnet_id       = ""
      register = {
        gitlab_host          = "gitlab.example.com"
        tld                  = "tld.example.com"
        ci_token             = "XxXxXxXxXxXx"
        default_docker_image = "alpine:3.12.0"
        default_tags         = "tag-a,tag-b"
        locked               = false
        run_untagged         = false
        runner_concurrency   = 1
      }
    }
  }
}
