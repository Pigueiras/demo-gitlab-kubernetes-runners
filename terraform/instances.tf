resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = file("~/.ssh/id_rsa.pub")
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "gitlab" {
  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = true
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.mykey.key_name
  security_groups             = [aws_security_group.allow_everything_from_my_ip.id, aws_security_group.allow_runners_to_port_80.id]
  subnet_id                   = aws_subnet.mysubnet.id
  root_block_device {
    volume_size = 50
    volume_type = "gp2"
  }

  provisioner "local-exec" {
    working_dir = "../ansible"
    command = <<EOF
aws ec2 wait instance-status-ok --instance-ids ${self.id}
ansible-playbook --extra-vars 'host_reference=tag_Name_${self.tags.Name} gitlab_public_dns=${self.public_dns}' gitlab.yml
EOF
  }

  tags = {
    Name = "gitlab"
  }
}

resource "aws_instance" "kubernetes" {
  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = true
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.mykey.key_name
  security_groups             = [aws_security_group.allow_everything_from_my_ip.id]
  subnet_id                   = aws_subnet.mysubnet.id

  root_block_device {
    volume_size = 50
    volume_type = "gp2"
  }

  # we need to connect the runner with the kubernetes runner after it has been configured
  depends_on = [ aws_instance.gitlab ]

  provisioner "local-exec" {
    working_dir = "../ansible"
    command = <<EOF
aws ec2 wait instance-status-ok --instance-ids ${self.id}
ansible-playbook --extra-vars 'host_reference=tag_Name_${self.tags.Name} gitlab_public_dns=${aws_instance.gitlab.public_dns}' kubernetes.yml
EOF
  }

  tags = {
    Name = "kubernetes"
  }
}

