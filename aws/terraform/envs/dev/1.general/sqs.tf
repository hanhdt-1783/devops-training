resource "aws_sqs_queue" "posts" {
  name                       = "${var.project}-${var.env}-posts-queue"
  visibility_timeout_seconds = 60
  message_retention_seconds  = 86400
  delay_seconds              = 0
  receive_wait_time_seconds  = 10
}

resource "aws_sqs_queue" "posts_dlq" {
  name = "${var.project}-${var.env}-posts-dlq"
}

resource "aws_sqs_queue_redrive_policy" "posts_redrive" {
  queue_url = aws_sqs_queue.posts.url
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.posts_dlq.arn
    maxReceiveCount     = 3
  })
}
