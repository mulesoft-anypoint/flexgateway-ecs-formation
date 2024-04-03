#!/bin/bash

echo "EC2 LAUNCH SCRIPT: START"

#COPYING ECS CLUSTER NAME IN REQUIRED LOCATION
echo ECS_CLUSTER=${aws_ecs_cluster_name} >> /etc/ecs/ecs.config

#COPYING DOCKER COMPOSE FILE AND ENVIRONMENT FILES
mkdir -p ${registration_location}

cat << 'EOF' > ${registration_location}/registration.yaml
${registration_file_content}
EOF


echo "EC2 LAUNCH SCRIPT: END"
