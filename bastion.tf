resource "aws_security_group" "bastion_host_security_group" {
  name = "bastion-host-security-group"
  vpc_id = module.tf_demo_vpc.vpc_id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion_host" {
  ami           = "ami-0f61af304b14f15fb"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = module.public_subnet_a.id
  key_name = "patrick.amsler@srf.ch"
  security_groups = [aws_security_group.bastion_host_security_group.id]
  tags = {
    Name = "bastion_host"
  }
}

output "bastion_host_global_ips" {
  value = [aws_instance.bastion_host.public_ip]
}