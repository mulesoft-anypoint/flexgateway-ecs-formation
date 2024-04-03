# Terraform AWS Infrastructure for Flex Gateway

This project leverages Terraform to create a comprehensive AWS infrastructure, supporting high availability and scalability for Flex Gateway containers. It includes setup for a VPC, multi-AZ subnets, an Internet Gateway, ECS on EC2 instances with autoscaling, and an Application Load Balancer (ALB) for efficient traffic distribution.

## Project Structure

- **`data.tf`**: Contains all the data sources and Terraform local data needed for the project.
- **`variable.tf`**: Defines variables used across the Terraform configurations.
- **`roles.tf`**: Specifies AWS IAM roles for secure access and operation within the AWS ecosystem.
- **`network.tf`**: Includes definitions for the VPC, subnets, and Internet Gateway to establish a solid network foundation.
- **`main.tf`**: Sets up the Terraform provider and general configurations crucial for initializing the Terraform AWS provider.
- **`loadbalancer.tf`**: Configures the ALB to manage traffic across ECS services, ensuring high availability and responsiveness.
- **`cluster.tf`**: Outlines the ECS cluster setup, focusing on scalability and management of containerized applications.
- **`flexgateway.tf`**: Contains the ECS task and service definition for deploying Flex Gateway, tailored to use the "host" network mode for enhanced performance.

## Prerequisites

Ensure you have the following tools installed on your local machine:
- Terraform (version 0.12 or newer)
- AWS CLI (configured with user credentials)

## Setting Up AWS Credentials

1. If not already done, configure your AWS CLI by running:
  ```sh
  aws configure
  ```

2. Follow the prompts to input your AWS Access Key ID, Secret Access Key, and default region. This step is crucial for Terraform to manage resources on AWS on your behalf.

## Variables

Various variables are defined for customizing the deployment, including:

| Variable | Type | Default Value | Description |
|----------|------|---------------|-------------|
| `region` | string | `"eu-west-1"` | The AWS region where resources will be deployed. |
| `name` | string | `"fg-demo"` | Prefix used for naming AWS resources. |
| `cluster_autoscaling_min_size` | number | `1` | The minimum size of the cluster autoscaling group. |
| `cluster_autoscaling_max_size` | number | `2` | The maximum size of the cluster autoscaling group. |
| `cluster_autoscaling_minimum_scaling_step_size` | number | `1` | The minimum scaling step size for autoscaling adjustments. |
| `cluster_autoscaling_maximum_scaling_step_size` | number | `1` | The maximum scaling step size for autoscaling adjustments. |
| `cluster_autoscaling_is_managed_by_ecs` | string | `"ENABLED"` | Whether ECS manages the cluster autoscaling (`ENABLED` or `DISABLED`). |
| `cluster_autoscaling_target_capacity` | number | `100` | Target utilization percentage for the ECS capacity provider. |
| `cloudwatch_retention` | number | `1` | The retention period, in days, for CloudWatch logs. |
| `registration_location` | string | `"/opt/registration"` | The location of the registration folder on the host machine. |
| `ec2_type` | string | `"t2.micro"` | The EC2 instance type used for the deployment. |
| `flexgateway_docker_image` | string | `"mulesoft/flex-gateway"` | The Docker image for FlexGateway. |
| `flexgateway_docker_image_version` | string | `"1.6.2"` | The version of the FlexGateway Docker image. |
| `flexgateway_task_memory` | number | `256` | The amount of memory allocated for the FlexGateway task. |
| `flexgateway_desired_replicas_count` | number | `1` | The desired number of FlexGateway replicas. |
| `flexgateway_autoscaling_min_capacity` | number | `1` | The minimum capacity for FlexGateway autoscaling. |
| `flexgateway_autoscaling_max_capacity` | number | `2` | The maximum capacity for FlexGateway autoscaling. |
| `flexgateway_autoscaling_avg_cpu_target` | number | `80` | The average CPU utilization target for FlexGateway autoscaling. |

## Deploying the Infrastructure

To deploy the AWS infrastructure using Terraform, follow these steps:

1. Initialize Terraform in your project directory:
```sh
terraform init
```
This command prepares your directory for other Terraform commands.

2. Review the Plan to see the changes Terraform will apply:
```sh
terraform plan
```
This step allows you to verify the actions Terraform will perform before making any changes to your AWS infrastructure.

3. Apply the Configuration to start the deployment:
```sh
terraform apply
```
Confirm the action to proceed. Terraform will now create the resources as defined in your configuration files.

## Special Note: ECS "Host" Network Mode

This project's ECS services are configured to use the "host" network mode. This approach enables the ECS tasks to share the network stack of the EC2 host instances, offering simplified network configuration and potentially better performance. However, it's important to understand the implications:

  * Each task deployed on an EC2 instance will share the instance's IP address and network ports. As a result, port conflicts must be managed carefully.
  * This mode is ideal for applications that do not require the network isolation provided by the awsvpc mode.

## Cleanup

To remove the deployed resources and prevent further charges, run:

```sh
terraform destroy
```

Confirm the destruction to let Terraform clean up all resources created during the deployment process.

