# Info for this AMI can be found here: https://wiki.debian.org/Cloud/AmazonEC2Image/Bullseye
data "aws_ami" "debian_bullseye" {
  provider = aws.ci

  owners      = ["136693071363"]
  most_recent = true

  filter {
    name   = "name"
    values = ["debian-11-amd64-2022*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "random_pet" "runner_id" {
  for_each = var.runner_ec2
  keepers = {
    ami_id    = data.aws_ami.debian_bullseye.id
    subnet_id = each.value.instance.subnet_id
    pub_key   = each.value.instance.ssh_key_pub
    user_data = templatefile(
      "${path.module}/templates/gl_runner_cloud_init.tmpl",
      {
        glr_version : each.value.glr_version,
        reg : each.value.register,
        config : each.value.config,
        swap_enabled : each.value.instance.swap_size != 0,
        s3_cache_config : merge(
          var.s3_cache_config,
          { bucket = var.s3_cache_config.enabled ? aws_s3_bucket.gitlab_runner_s3_cache["enabled"].bucket : "" },
          each.value.s3_cache
        )
      }
    )
  }
}

resource "aws_iam_instance_profile" "terraform_runner" {
  provider = aws.ci

  for_each = var.runner_ec2
  name     = "${var.prefix}-${random_pet.runner_id[each.key].id}-${each.value.instance.role}-profile"
  role     = each.value.instance.role
}

resource "aws_key_pair" "gitlab_runner_ssh" {
  provider = aws.ci

  for_each        = var.runner_ec2
  key_name_prefix = "${var.prefix}-glr-${random_pet.runner_id[each.key].id}"
  public_key      = random_pet.runner_id[each.key].keepers.pub_key
}

resource "aws_instance" "gitlab_runner" {
  for_each = var.runner_ec2

  provider = aws.ci

  ami                         = random_pet.runner_id[each.key].keepers.ami_id
  instance_type               = each.value.instance.type
  vpc_security_group_ids      = each.value.instance.security_groups
  subnet_id                   = random_pet.runner_id[each.key].keepers.subnet_id
  associate_public_ip_address = true
  monitoring                  = true
  disable_api_termination     = false
  iam_instance_profile        = aws_iam_instance_profile.terraform_runner[each.key].name
  key_name                    = aws_key_pair.gitlab_runner_ssh[each.key].key_name
  tags = {
    Name       = "${var.prefix}-gitlab-runner-${random_pet.runner_id[each.key].id}"
    RunnerTags = each.value.register.default_tags
  }
  volume_tags = {
    Name       = "${var.prefix}-gitlab-runner-${random_pet.runner_id[each.key].id}"
    RunnerTags = each.value.register.default_tags
  }
  root_block_device {
    volume_type = "gp3"
    volume_size = each.value.instance.ebs_root_size
  }
  dynamic "ebs_block_device" {
    for_each = each.value.instance.swap_size != 0 ? toset(["swapon"]) : toset([])
    content {
      device_name = "/dev/xvds"
      volume_type = "gp3"
      volume_size = each.value.instance.swap_size
    }
  }
  credit_specification {
    cpu_credits = each.value.instance.credit_spec
  }
  lifecycle {
    ignore_changes        = [tags]
    create_before_destroy = true
  }
  user_data                   = random_pet.runner_id[each.key].keepers.user_data
  user_data_replace_on_change = true
}
