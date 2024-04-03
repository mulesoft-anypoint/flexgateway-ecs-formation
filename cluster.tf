# --- ECS Cluster ---

resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster"
}


# --- ECS Launch Template ---

resource "aws_launch_template" "ecs_ec2" {
  name_prefix            = "${var.name}-ecs-ec2-"
  image_id               = data.aws_ssm_parameter.ecs_node_ami.value
  instance_type          = var.ec2_type
  vpc_security_group_ids = [aws_security_group.ecs_node_sg.id]

  iam_instance_profile { arn = aws_iam_instance_profile.ecs_node.arn }
  monitoring { enabled = true }

  user_data = local.ec2_launch_cloud_init_gzip
}


# --- ECS AUTOSCALING-GROUP ---

resource "aws_autoscaling_group" "ecs" {
  name_prefix               = "${var.name}-ecs-asg-"
  vpc_zone_identifier       = aws_subnet.public[*].id
  min_size                  = var.cluster_autoscaling_min_size
  max_size                  = var.cluster_autoscaling_max_size
  health_check_grace_period = 0
  health_check_type         = "EC2"
  protect_from_scale_in     = false

  launch_template {
    id      = aws_launch_template.ecs_ec2.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-ecs-cluster"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}


# --- ECS Capacity Provider ---

resource "aws_ecs_capacity_provider" "main" {
  name = "${var.name}-ecs-ec2"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = var.cluster_autoscaling_maximum_scaling_step_size
      minimum_scaling_step_size = var.cluster_autoscaling_minimum_scaling_step_size
      status                    = var.cluster_autoscaling_is_managed_by_ecs
      target_capacity           = var.cluster_autoscaling_target_capacity
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = [aws_ecs_capacity_provider.main.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    base              = 1
    weight            = 100
  }
}

# --- Cloud Watch Logs ---

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.name}"
  retention_in_days = var.cloudwatch_retention
}




