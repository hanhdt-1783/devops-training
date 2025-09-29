resource "aws_cloudwatch_metric_alarm" "eventbridge_failed" {
  alarm_name          = "${var.project}-${var.env}-eventbridge-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FailedInvocations"
  namespace           = "AWS/Events"
  period              = 300
  statistic           = "Sum"
  threshold           = 0

  dimensions = {
    RuleName = data.terraform_remote_state.general.outputs.scheduler_rule_name
  }

  alarm_description  = "Alarm when EventBridge scheduler fails to invoke target"
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "post_failure" {
  alarm_name          = "${var.project}-${var.env}-post-failure"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "PostFailureCount"
  namespace           = "Custom/SocialPosting"
  period              = 300
  statistic           = "Sum"
  threshold           = 0

  alarm_description  = "Alarm when there are failed posts"
  treat_missing_data = "notBreaching"
}
