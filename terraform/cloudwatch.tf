resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/devsecops/demo/app"
  retention_in_days = 7

  tags = {
    Name        = "Application Logs"
    Description = "Centralized logging for demo app"
  }
}

resource "aws_cloudwatch_log_group" "pipeline_logs" {
  name              = "/devsecops/demo/pipeline"
  retention_in_days = 7

  tags = {
    Name        = "Pipeline Logs"
    Description = "CI/CD pipeline execution logs"
  }
}

resource "aws_cloudwatch_log_group" "security_logs" {
  name              = "/devsecops/demo/security"
  retention_in_days = 30

  tags = {
    Name        = "Security Logs"
    Description = "Security scan and audit logs"
  }
}

resource "aws_cloudwatch_log_stream" "app_stream" {
  name           = "application-stream"
  log_group_name = aws_cloudwatch_log_group.app_logs.name
}

resource "aws_cloudwatch_log_stream" "error_stream" {
  name           = "error-stream"
  log_group_name = aws_cloudwatch_log_group.app_logs.name
}

resource "aws_cloudwatch_log_metric_filter" "error_count" {
  name           = "ErrorCount"
  log_group_name = aws_cloudwatch_log_group.app_logs.name
  pattern        = "[time, request_id, level = ERROR*, ...]"

  metric_transformation {
    name      = "ErrorCount"
    namespace = "DevSecOps/Demo"
    value     = "1"
    unit      = "Count"
  }
}

resource "aws_cloudwatch_log_metric_filter" "warning_count" {
  name           = "WarningCount"
  log_group_name = aws_cloudwatch_log_group.app_logs.name
  pattern        = "[time, request_id, level = WARN*, ...]"

  metric_transformation {
    name      = "WarningCount"
    namespace = "DevSecOps/Demo"
    value     = "1"
    unit      = "Count"
  }
}

resource "aws_cloudwatch_log_metric_filter" "security_events" {
  name           = "SecurityEvents"
  log_group_name = aws_cloudwatch_log_group.security_logs.name
  pattern        = "[time, level, event_type = *SECURITY*, ...]"

  metric_transformation {
    name      = "SecurityEventCount"
    namespace = "DevSecOps/Demo"
    value     = "1"
    unit      = "Count"
  }
}
output "app_log_group_name" {
  description = "Name of the application log group"
  value       = aws_cloudwatch_log_group.app_logs.name
}

output "app_log_stream_name" {
  description = "Name of the application log stream"
  value       = aws_cloudwatch_log_stream.app_stream.name
}

output "security_log_group_name" {
  description = "Name of the security log group"
  value       = aws_cloudwatch_log_group.security_logs.name
}
