output "bucket_names" {
  value = aws_s3_bucket.my_bucket[*].bucket
}