resource "aws_dynamodb_table" "posts" {
  name           = "${var.project}-${var.env}-posts"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "post_id"
  range_key      = "user_id"

  attribute {
    name = "post_id"
    type = "S"
  }

  attribute {
    name = "user_id"
    type = "S"
  }
}
