data "aws_ami" "gitlab_runner_docker" {
  for_each         = var.runner_ec2
  executable_users = ["self"]
  most_recent      = true
  owners           = [var.ami_owner]
  name_regex       = "centos_7|buster"

  filter {
    name   = "name"
    values = ["ci-cd_${each.value["ami_slug"]}.gitlab-runner_*"]
  }
}

resource "aws_iam_instance_profile" "terraform_runner" {
  name = "${var.prefix}-${var.runner_ec2.instance_role}-terraform-runner"
  role = var.runner_ec2.instance_role
}

resource "aws_key_pair" "gitlab_runner_ssh" {
  key_name   = "${var.prefix}-gitlab-runner-ssh"
  public_key = var.runner_ec2.ssh_key_pub
}

resource "random_pet" "runner_id" {
  for_each = var.runner_ec2
  keepers = {
    ami_id    = data.aws_ami.gitlab_runner_docker[each.key].id
    subnet_id = each.value.subnet_id
  }
}

resource "aws_instance" "gitlab_runner" {
  for_each                    = var.runner_ec2
  ami                         = random_pet.runner_id[each.key].keepers.ami_id
  instance_type               = each.value.instance_type
  vpc_security_group_ids      = each.value.security_groups
  subnet_id                   = random_pet.runner_id[each.key].keepers.subnet_id
  associate_public_ip_address = true
  monitoring                  = true
  disable_api_termination     = false
  iam_instance_profile        = aws_iam_instance_profile.terraform_runner.name
  key_name                    = aws_key_pair.gitlab_runner_ssh.key_name
  tags = {
    Name = "${var.prefix}-gitlab-runner-${random_pet.runner_id[each.key].id}"
  }
  volume_tags = {
    Name = "${var.prefix}-gitlab-runner"
  }
  root_block_device {
    volume_type = "gp2"
    volume_size = "8"
  }
  credit_specification {
    cpu_credits = var.runner_ec2.credit_spec
  }
  lifecycle {
    ignore_changes        = all
    create_before_destroy = true
  }
  user_data = templatefile(
    "${path.module}/templates/gl_runner_cloud_init.tmpl",
    {
      hostname : "glr-${random_pet.runner_id[each.key].id}",
      distro : regex(
        "(?P<dist>${data.aws_ami.gitlab_runner_docker[each.key].name_regex})",
        data.aws_ami.gitlab_runner_docker[each.key].name
      )["dist"],
      tld : each.value.register.tld,
      registration_token : each.value.register.ci_token,
      docker_image : each.value.register.default_docker_image,
      runner_tags : each.value.register.default_tags,
      gitlab_host : each.value.register.gitlab_host,
      locked : each.value.register.locked,
      run_untagged : each.value.register.run_untagged,
      runner_concurrency : each.value.register.runner_concurrency
    }
  )
}
