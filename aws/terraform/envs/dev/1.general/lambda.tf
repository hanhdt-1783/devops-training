resource "aws_lambda_function" "post_worker" {
  function_name = "${var.project}-${var.env}-post-worker"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  filename          = "${path.module}/../../../../lambda/post-worker.zip"
  source_code_hash  = filebase64sha256("${path.module}/../../../../lambda/post-worker.zip")

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

 environment {
    variables = {
      DYNAMODB_TABLE   = data.terraform_remote_state.database.outputs.posts_table_name
      REGION           = var.region
      POSTS_QUEUE_URL  = aws_sqs_queue.posts.url
    }
  }
}

resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.posts.arn
  function_name    = aws_lambda_function.post_worker.arn
  batch_size       = 1
  enabled          = true
}
