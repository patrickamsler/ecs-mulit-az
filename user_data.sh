#!/bin/bash

# Adding cluster name in ecs config
sudo mkdir -p /etc/ecs
echo 'ECS_CLUSTER=tf-demo-cluster' | sudo tee -a /etc/ecs/ecs.config > /dev/null
cat /etc/ecs/ecs.config | grep "ECS_CLUSTER"

# Installing the Amazon ECS container agent
sudo amazon-linux-extras disable docker
sudo amazon-linux-extras install -y ecs; sudo systemctl enable --now ecs