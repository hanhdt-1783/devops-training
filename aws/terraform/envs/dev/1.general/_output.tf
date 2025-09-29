output "scheduler_rule_name" {
  description = "The name of the EventBridge Scheduler rule"
  value       = aws_cloudwatch_event_rule.scheduler.name
}
