terraform {
  required_providers {
    aws    = "~> 2.66"
    random = "~> 2.2"
  }
}
// I need a way to convert count into a unique list of runners.
// So let's say I start with a single runner and later add one:
//   with count:
//    aws_instance.run[0] <* start
//    --
//    aws_instance.run[0] <* end
//    aws_instance.run[1]
//
// That's all good. Now, remove the first without killing the second. :(
// If I had unique names, then I could have
//   with names:
//    aws_instance.run['12.10-001'] <* start
//    --
//    aws_instance.run['12.10-001'] <* end
//    aws_instance.run['13.1-001']
//
// Then removing the first is way easier. But I need to figure out how to make this work ..
// This is not helpful if you just start with a single v12 runner and want to replace it.
// But it will help replace a single v12 with a single v13.
// TODO: Figure out cleaner ways to handle this?
locals {
  runner_instances = flatten([
    for runner_ver in var.ami_slugs : [
      for i in range(var.runner_ec2.count) : {
        id           = i
        glr_rel_slug = runner_ver
      }
    ]
  ])

  runner_instances_map = {
    for instance in local.runner_instances : "${instance.glr_rel_slug}_${instance.id}" => instance
  }
}

output "runner_instances" {
  value = local.runner_instances
}
output "runner_map" {
  value = local.runner_instances_map
}
