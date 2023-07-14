module "packer_node" {
  source   = "../../modules/packer-docker-node"

  project       = "demo"
  node          = "packer"
  owner         = "me"
  instance_type = "t3.micro"
}
