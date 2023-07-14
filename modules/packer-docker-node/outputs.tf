output "build_uuid" {
  value = resource.packer_image.image.build_uuid
}

output "ip" {
  value = aws_instance.packer.public_ip
}
