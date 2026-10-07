
locals {

  env = {
    dev = {
      instance_count = 1
      bucket_count   = 1
      table_count    = 1
    }

    stg = {
      instance_count = 2
      bucket_count   = 2
      table_count    = 2
    }
    prod = {
      instance_count = 4
      bucket_count   = 3
      table_count    = 2
    }
  }

  current = lookup(local.env, terraform.workspace, local.env["dev"])

}

module "ec2" {
  source = "./modules/ec2"

  env             = terraform.workspace
  instance_count  = local.current.instance_count
  ami             = var.ami
  instance_type   = var.instance_type
  key_public_path = var.key_public_path
}

module "s3" {
  source = "./modules/s3"

  env          = terraform.workspace
  bucket_count = local.current.bucket_count
}

module "dynamodb" {
  source = "./modules/dynamodb"

  env         = terraform.workspace
  table_count = local.current.table_count
}