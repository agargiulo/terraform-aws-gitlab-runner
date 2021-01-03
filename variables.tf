variable "prefix" { default = "gitlab-runner" }

variable "ami_slugs" {
  default = [
    "main"
  ]
}

variable "ami_owner" {
  default = "self"
}

variable "runner_ec2" {
  default = {
    // This is the count PER item in `var.ami_slugs`
    count           = 1
    instance_type   = "t2.micro"
    security_groups = []
    subnet_id       = ""
    ssh_key_pub     = ""
    instance_role   = "terraform_runner"
    credit_spec     = "standard"
  }
}

variable "runner_register" {
  default = {
    gitlab_host          = "example.com"
    tld                  = ""
    ci_token             = ""
    default_docker_image = "alpine:3.12.0"
    default_tags         = "tag-a,tag-b"
    locked               = false
    run_untagged         = false
    runner_concurrency   = 3
  }
}
