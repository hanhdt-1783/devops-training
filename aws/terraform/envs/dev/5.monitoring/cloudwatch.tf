resource "aws_cloudwatch_log_group" "ecs_api" {
  name              = "/ecs/${var.project}-${var.env}-api"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "lambda_worker" {
  name              = "/lambda/${var.project}-${var.env}-post-worker"
  retention_in_days = 7
}
