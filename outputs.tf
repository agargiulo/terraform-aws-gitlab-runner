output "gitlab_runner" {
  value = {
    gitlab_runner = {
      instance_profile = aws_iam_instance_profile.terraform_runner
      ssh_key_pair     = aws_key_pair.gitlab_runner_ssh.key_name
      runners = [
        for runner in aws_instance.gitlab_runner :
        runner.id
      ]
    }
  }
}
