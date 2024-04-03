locals {
  azs_count = 2
  azs_names = data.aws_availability_zones.available.names

  ec2_launch_script_parts = [
    {
      filepath = "${path.module}/resources/ec2_launch_script.sh"
      content-type = "text/x-shellscript"
      vars = {
        aws_ecs_cluster_name          = aws_ecs_cluster.main.name
        registration_location         = var.registration_location
        registration_file_content     = file("${path.module}/resources/registration.yaml")
      }
    }
  ]

  ec2_launch_script_parts_rendered = [ for part in local.ec2_launch_script_parts : <<EOF
--MIMEBOUNDARY
Content-Transfer-Encoding: 7bit
Content-Type: ${part.content-type}
Mime-Version: 1.0

${templatefile(part.filepath, part.vars)}
    EOF
  ]

  ec2_launch_cloud_init_gzip = base64gzip(templatefile("${path.module}/resources/cloud-init.tpl", {cloud_init_parts = local.ec2_launch_script_parts_rendered}))
}

data "aws_availability_zones" "available" { state = "available" }

data "aws_ssm_parameter" "ecs_node_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}