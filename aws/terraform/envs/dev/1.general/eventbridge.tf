resource "aws_cloudwatch_event_rule" "scheduler" {
  name                = "${var.project}-${var.env}-post-scheduler"
  description         = "Trigger scheduled posts"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "send_to_sqs" {
  rule      = aws_cloudwatch_event_rule.scheduler.name
  target_id = "sqs"
  arn       = aws_sqs_queue.posts.arn
  role_arn  = aws_iam_role.eventbridge_to_sqs.arn
}
