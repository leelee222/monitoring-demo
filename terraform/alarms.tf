resource "aws_sns_topic" "alerts" {
  name         = "devsecops-demo-alerts"
  display_name = "DevSecOps Monitoring Alerts"

  tags = {
    Name        = "Monitoring Alerts"
    Description = "Central topic for all monitoring alerts"
  }
}

resource "aws_sns_topic_subscription" "alert_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-alert"
  alarm_description   = "Alert when CPU utilization exceeds 80%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Name     = "High CPU Alert"
    Severity = "Warning"
  }
}

resource "aws_cloudwatch_metric_alarm" "high_memory" {
  alarm_name          = "high-memory-alert"
  alarm_description   = "Alert when memory utilization exceeds 85%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 85
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Name     = "High Memory Alert"
    Severity = "Warning"
  }
}

resource "aws_cloudwatch_metric_alarm" "high_error_rate" {
  alarm_name          = "high-error-rate-alert"
  alarm_description   = "Alert when error count exceeds 10 in 5 minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ErrorCount"
  namespace           = "DevSecOps/Demo"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Name     = "High Error Rate Alert"
    Severity = "Critical"
  }
}

resource "aws_cloudwatch_metric_alarm" "security_events" {
  alarm_name          = "security-event-alert"
  alarm_description   = "Alert on any security event detection"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "SecurityEventCount"
  namespace           = "DevSecOps/Demo"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Name     = "Security Event Alert"
    Severity = "Critical"
  }
}

resource "aws_cloudwatch_metric_alarm" "missing_logs" {
  alarm_name          = "missing-logs-alert"
  alarm_description   = "Alert when no logs received for 10 minutes"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "IncomingLogEvents"
  namespace           = "AWS/Logs"
  period              = 600
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "breaching"

  dimensions = {
    LogGroupName = aws_cloudwatch_log_group.app_logs.name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Name     = "Missing Logs Alert"
    Severity = "Warning"
  }
}

resource "aws_cloudwatch_metric_alarm" "pipeline_failure" {
  alarm_name          = "pipeline-failure-alert"
  alarm_description   = "Alert on CI/CD pipeline failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "PipelineFailureCount"
  namespace           = "DevSecOps/Demo"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Name     = "Pipeline Failure Alert"
    Severity = "High"
  }
}
output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = aws_sns_topic.alerts.arn
}

output "alarm_names" {
  description = "Names of all CloudWatch alarms"
  value = [
    aws_cloudwatch_metric_alarm.high_cpu.alarm_name,
    aws_cloudwatch_metric_alarm.high_memory.alarm_name,
    aws_cloudwatch_metric_alarm.high_error_rate.alarm_name,
    aws_cloudwatch_metric_alarm.security_events.alarm_name,
    aws_cloudwatch_metric_alarm.missing_logs.alarm_name,
    aws_cloudwatch_metric_alarm.pipeline_failure.alarm_name,
  ]
}
