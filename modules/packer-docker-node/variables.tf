variable "region" {
  default = "eu-west-1"
} 

variable "owner" {
  default = "ruan"
}

variable "project" {
  default = "packer-project"
}

variable "node" {
  default = "dockernode"
}

variable "builder_instance_type" {
  default = "t2.micro"
}

variable "instance_type" {
  default = "t3.micro"
}
