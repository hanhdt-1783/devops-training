output "posts_table_name" {
  value       = aws_dynamodb_table.posts.name
  description = "Name of DynamoDB table for posts"
}
