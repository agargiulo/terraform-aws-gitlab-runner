terraform {
  required_providers {
    aws = {
      source  = "registry.terraform.io/hashicorp/aws"
      version = "~> 6"

      configuration_aliases = [aws.ci, aws.route53]
    }
    random = {
      source  = "registry.terraform.io/hashicorp/random"
      version = "~> 3"
    }
  }
}
