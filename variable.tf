variable "region" {
  type = string
  default = "eu-west-1"
}

variable "name" {
  default = "fg-demo"
}

variable "cluster_autoscaling_min_size" {
  type = number
  default = 1
}

variable "cluster_autoscaling_max_size" {
  type = number
  default = 2
}

variable "cluster_autoscaling_minimum_scaling_step_size" {
  type = number
  default = 1
}

variable "cluster_autoscaling_maximum_scaling_step_size" {
  type = number
  default = 1
}

variable "cluster_autoscaling_is_managed_by_ecs" {
  type = string
  default = "ENABLED" # supported values: ENABLED or DISABLED
}

variable "cluster_autoscaling_target_capacity" {
  type = number
  default = 100 # number between 1 and 100
  description = "Target utilization for the ECS capacity provider. A number between 1 and 100."
}

variable "cloudwatch_retention" {
  type = number
  default = 1
  description = "The cloudwatch retention in days"
}

variable "registration_location" {
  type = string
  default = "/opt/registration"
  description = "location of the registration folder in the host machine"
}

variable "ec2_type" {
  type = string
  default = "t2.micro"
}

variable "flexgateway_docker_image" {
  type = string
  default = "mulesoft/flex-gateway"
}

variable "flexgateway_docker_image_version" {
  type = string
  default = "1.6.2"
}

variable "flexgateway_task_memory" {
  type = number
  default = 256
}

variable "flexgateway_desired_replicas_count" {
  type = number
  default = 1
}

variable "flexgateway_autoscaling_min_capacity" {
  type = number
  default = 1
}

variable "flexgateway_autoscaling_max_capacity" {
  type = number
  default = 2
}

variable "flexgateway_autoscaling_avg_cpu_target" {
  type = number
  default = 80
  description = "Target value for the cpu matric to trigger scale"
}

variable "flexgateway_autoscaling_avg_mem_target" {
  type = number
  default = 80
  description = "Target value for the memory matric to trigger scale"
}

variable "flexgateway_autoscaling_scale_in_cooldown" {
  type = number
  default = 300
  description = "Amount of time, in seconds, after a scale in activity completes before another scale in activity can start."
}

variable "flexgateway_autoscaling_scale_out_cooldown" {
  type = number
  default = 300
  description = "Amount of time, in seconds, after a scale out activity completes before another scale out activity can start."
}