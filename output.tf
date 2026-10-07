output "current_workspace" {
  value = terraform.workspace
}

output "ec2_instance_ids" {
  value = module.ec2.instance_ids
}

output "ec2_public_ips" {
  value = module.ec2.public_ips
}

output "s3_bucket_names" {
  value = module.s3.bucket_names
}

output "dynamodb_table_names" {
  value = module.dynamodb.table_names
}

