data "local_file" "ansible_tasks" {
  filename = "../../ansible/docker-node/tasks/setup.yml"
}

data "packer_files" "image" {
  file = "../../packer/image.pkr.hcl"
}

resource "packer_image" "image" {
  file = data.packer_files.image.file
  
  variables = {
    project = var.project
    node    = var.node
    builder_instance_type = var.builder_instance_type
    region  = var.region
  }

  triggers = {
    files_hash         = data.packer_files.image.files_hash
    ansible_tasks_hash = data.local_file.ansible_tasks.content_sha512
  }
}

data "aws_ami" "latest_packer_ami" {
  most_recent = true
  owners = ["self"]

  filter {
    name   = "name"
    values = ["${var.project}-${var.node}-*"]
  }

  filter {
    name   = "tag:NodeID"
    values = ["${var.node}"]
  }

  depends_on = [
    packer_image.image
  ]

}

resource "aws_key_pair" "ruan" {
  key_name   = "${var.owner}-terraform"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "packer" {
  ami           = data.aws_ami.latest_packer_ami.id
  instance_type = "t3.micro"

  tags = {
    Name = "${var.owner}-packer-ec2-instance"
    UseCase = "packer"
  }

  key_name               = aws_key_pair.ruan.key_name
  vpc_security_group_ids = [aws_security_group.packer.id]

  root_block_device {
    delete_on_termination = true
    volume_size           = 20
    volume_type           = "gp3"
  }
}

resource "aws_security_group" "packer" {
  name_prefix = "${var.owner}-packer-ec2-sg"
  
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


