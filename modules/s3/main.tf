resource "aws_s3_bucket" "my_bucket" {
    count = var.bucket_count
    bucket = "${var.env}-terraform-workspace-automate-bucket-${count.index+1}"
}