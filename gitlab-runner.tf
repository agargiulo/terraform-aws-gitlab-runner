data "aws_ami" "gitlab_runner_centos7_docker" {
  executable_users = ["self"]
  most_recent      = true
  owners           = [var.ami.owner]

  filter {
    name   = "name"
    values = ["ci-cd_${var.ami.version_slug}.gitlab-runner_${var.runner_version}.centos_7.*"]
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
  count = var.runner_ec2.count
  keepers = {
    ami_id    = data.aws_ami.gitlab_runner_centos7_docker.id
    subnet_id = var.runner_ec2.subnet_id
  }
}

resource "aws_instance" "gitlab_runner" {
  count                       = var.runner_ec2.count
  ami                         = random_pet.runner_id[count.index].keepers.ami_id
  instance_type               = var.runner_ec2.instance_type
  vpc_security_group_ids      = var.runner_ec2.security_groups
  subnet_id                   = random_pet.runner_id[count.index].keepers.subnet_id
  associate_public_ip_address = true
  monitoring                  = true
  disable_api_termination     = false
  iam_instance_profile        = aws_iam_instance_profile.terraform_runner.name
  key_name                    = aws_key_pair.gitlab_runner_ssh.key_name
  tags = {
    Name = "${var.prefix}-gitlab-runner-${random_pet.runner_id[count.index].id}"
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
      hostname : "gitlab-ci-runner-${random_pet.runner_id[count.index].id}.build.${var.runner_register.tld}",
      registration_token : var.runner_register.ci_token,
      docker_image : var.runner_register.default_docker_image,
      runner_tags : var.runner_register.default_tags,
      gitlab_host : var.runner_register.gitlab_host,
      locked : var.runner_register.locked,
      run_untagged : var.runner_register.run_untagged,
      runner_concurrency : var.runner_register.runner_concurrency
    }
  )
}
