# --- ECS Task Definition ---

resource "aws_ecs_task_definition" "flexgateway" {
  family             = "${var.name}-flexgateway"
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_exec_role.arn
  network_mode       = "host"
  memory             = var.flexgateway_task_memory

  container_definitions = jsonencode([{
    name         = "app",
    image        = "${var.flexgateway_docker_image}:${var.flexgateway_docker_image_version}",
    essential    = true,
    portMappings = [{ containerPort = 8081, hostPort = 8081 }, { containerPort = 80, hostPort = 80 }],

    environment = []

    mountPoints = [{ containerPath = "/usr/local/share/mulesoft/flex-gateway/conf.d", sourceVolume = "registration" }]

    logConfiguration = {
      logDriver = "awslogs",
      options = {
        "awslogs-region"        = var.region,
        "awslogs-group"         = aws_cloudwatch_log_group.ecs.name,
        "awslogs-stream-prefix" = "app"
      }
    },
  }])

  volume {
    # should be defined in the EC2 template
    host_path = var.registration_location
    name = "registration"
  }
}


# --- ECS Service ---

resource "aws_ecs_service" "flexgateway" {
  name            = "${var.name}-flexgateway-svc2"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.flexgateway.arn
  desired_count   = var.flexgateway_desired_replicas_count

  #should be present only in case of awsvpc network mode in task definition
  # network_configuration {
  #   security_groups = [aws_security_group.ecs_task.id]
  #   subnets         = aws_subnet.public[*].id
  # }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    base              = 1
    weight            = 100
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  # Link with Load balancer
  depends_on = [aws_lb_target_group.app]

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = 80
  }
}


# NOTE - This should not be used along with "host" network mode
# --- ECS Service Auto Scaling Should ---

# resource "aws_appautoscaling_target" "ecs_target" {
#   service_namespace  = "ecs"
#   scalable_dimension = "ecs:service:DesiredCount"
#   resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.flexgateway.name}"
#   min_capacity       = var.flexgateway_autoscaling_min_capacity
#   max_capacity       = var.flexgateway_autoscaling_max_capacity
# }

# resource "aws_appautoscaling_policy" "ecs_target_cpu" {
#   name               = "${var.name}-flexgateway-app-scaling-policy-cpu"
#   policy_type        = "TargetTrackingScaling"
#   service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
#   resource_id        = aws_appautoscaling_target.ecs_target.resource_id
#   scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension

#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ECSServiceAverageCPUUtilization"
#     }

#     target_value       = var.flexgateway_autoscaling_avg_cpu_target
#     scale_in_cooldown  = var.flexgateway_autoscaling_scale_in_cooldown
#     scale_out_cooldown = var.flexgateway_autoscaling_scale_out_cooldown
#   }
# }

# resource "aws_appautoscaling_policy" "ecs_target_memory" {
#   name               = "${var.name}-flexgateway-app-scaling-policy-memory"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.ecs_target.resource_id
#   scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ECSServiceAverageMemoryUtilization"
#     }

#     target_value       = var.flexgateway_autoscaling_avg_mem_target
#     scale_in_cooldown  = var.flexgateway_autoscaling_scale_in_cooldown
#     scale_out_cooldown = var.flexgateway_autoscaling_scale_out_cooldown
#   }
# }