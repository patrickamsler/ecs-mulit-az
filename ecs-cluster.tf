// create the cluster
resource "aws_ecs_cluster" "tf-demo-ecs-cluster" {
  name = "tf-demo-cluster"
}

data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_agent" {
  name               = "ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}

resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       =  aws_iam_role.ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent"
  role = aws_iam_role.ecs_agent.name
}

resource "aws_security_group" "ecs_sg" {
  vpc_id = module.tf_demo_vpc.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.bastion_host_security_group.id] //only allow ingress from bastion host
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "ecs_launch_template" {
  name = "ecs_container_instance_launch_template"
  image_id = "ami-0f61af304b14f15fb"
  instance_type = "t2.micro"
  key_name = "patrick.amsler@srf.ch"
  user_data = base64encode(file("user_data.sh"))
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_agent.name
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ecs_container_instance"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "ecs_container_instance_volume"
    }
  }
}

resource "aws_autoscaling_group" "ecs_autoscaling_group" {
  name                      = "asg"
  vpc_zone_identifier       = [module.private_subnet_a.id, module.private_subnet_b.id]
  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }
  desired_capacity          = 2
  min_size                  = 1
  max_size                  = 10
  health_check_grace_period = 300
  health_check_type         = "EC2"
}