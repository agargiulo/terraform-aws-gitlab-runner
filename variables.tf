variable "prefix" { default = "gitlab-runner" }

variable "ami" {
  default = {
    owner       = "self"
    name_filter = ["gitlab-runner-*"]
    name_regex  = "^gitlab-runner-\\d+"
  }
}

variable "runner_ec2" {
  default = {
    count           = 1
    instance_type   = "t2.micro"
    security_groups = []
    subnet_id       = ""
    ssh_key_pub     = ""
    instance_role   = "terraform_runner"
  }
}

variable "runner_register" {
  default = {
    gitlab_host          = "example.com"
    tld                  = ""
    ci_token             = ""
    default_docker_image = "alpine:3.11.6"
    default_tags         = "tag-a,tag-b"
    locked               = false
    run_untagged         = false
    runner_concurrency   = 3
  }
}
