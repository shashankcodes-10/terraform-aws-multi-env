output "table_names" {
  value = aws_dynamodb_table.my_dynamodb[*].name
}
