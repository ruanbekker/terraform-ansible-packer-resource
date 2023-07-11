variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "node" {
  type    = string
  default = "dockernode"
}

variable "project" {
  type    = string
  default = "packer-project"
}

variable "builder_instance_type" {
  type    = string
  default = "t2.micro"
}

locals { 
  timestamp = regex_replace(timestamp(), "[- TZ:]", "") 
}

source "amazon-ebs" "amznlinux_dockernode_image" {
  ami_name      = "${var.project}-${var.node}-${local.timestamp}"
  instance_type = var.builder_instance_type
  region        = var.region
  profile       = "test"
  ssh_username  = "ec2-user"

  tags = {
    Name        = "${var.project}-${var.node}-${local.timestamp}"
    NodeID      = var.node
    Timestamp   = local.timestamp
  }

  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = "x86_64"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  temporary_iam_instance_profile_policy_document {
    Statement {
      Action   = [
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetAuthorizationToken",
        "ecr:CreateRepository",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage"
      ]
      Effect   = "Allow"
      Resource = ["*"]
    }
    Version = "2012-10-17"
  }

}

build {
  sources = ["source.amazon-ebs.amznlinux_dockernode_image"]

  provisioner "shell" {
    inline = [
      "echo installing ansible",
      "sudo yum update -y",
      "sudo amazon-linux-extras install ansible2 -y",
    ]
  }

  provisioner "ansible-local" {
    playbook_file   = "../../ansible/playbook.yml"
    playbook_dir    = "../../ansible"
    extra_arguments = [
      "--inventory inventory/default.yml"
    ]
  }

}
