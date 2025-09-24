locals {
  runner_route53_enabled = var.route53_zone_name != ""
}

data "aws_route53_zone" "gitlab_runners_zone" {
  count = local.runner_route53_enabled ? 1 : 0

  provider = aws.route53

  name = var.route53_zone_name
}

resource "aws_route53_record" "gitlab_runner_A" {
  for_each = local.runner_route53_enabled ? var.runner_ec2 : {}

  provider = aws.route53

  name    = "${random_pet.runner_id[each.key].id}.${var.route53_zone_name}."
  type    = "A"
  ttl     = 60
  records = [aws_instance.gitlab_runner[each.key].public_ip]
  zone_id = data.aws_route53_zone.gitlab_runners_zone[0].zone_id
}

resource "aws_route53_record" "gitlab_runner_TXT" {
  for_each = local.runner_route53_enabled ? var.runner_ec2 : {}

  provider = aws.route53

  name    = "${random_pet.runner_id[each.key].id}._tags.${var.route53_zone_name}."
  type    = "TXT"
  ttl     = 300
  records = [var.runner_ec2[each.key].register.default_tags]
  zone_id = data.aws_route53_zone.gitlab_runners_zone[0].zone_id
}

resource "aws_route53_record" "gitlab_runners_all_TXT" {
  count = local.runner_route53_enabled ? 1 : 0

  provider = aws.route53

  name    = "${var.route53_all_prefix}._runners.${var.route53_zone_name}."
  type    = "TXT"
  ttl     = 60
  records = [for run_key, runn in random_pet.runner_id : runn["id"]]
  zone_id = data.aws_route53_zone.gitlab_runners_zone[0].zone_id
}
