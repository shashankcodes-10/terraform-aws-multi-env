variable "ami" {
  type    = string
  default = "ami-0d76b909de1a0595d"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_public_path" {
  type    = string
  default = "terraform-key.pub"
}