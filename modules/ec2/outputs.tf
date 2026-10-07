output "instance_ids" {
    value = aws_instance.my-instance[*].id
}

output "public_ips" {
   value = aws_instance.my-instance.public_ip
}
