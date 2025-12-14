resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "devsecops-monitoring-demo"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x    = 0
        y    = 0
        width = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", { stat = "Average", label = "CPU Average" }],
            ["...", { stat = "Maximum", label = "CPU Max" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EC2 Instance CPU Utilization"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },

      {
        type = "metric"
        x    = 12
        y    = 0
        width = 12
        height = 6
        properties = {
          metrics = [
            ["CWAgent", "MemoryUtilization", { stat = "Average", label = "Memory Average" }],
            ["...", { stat = "Maximum", label = "Memory Max" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Memory Utilization"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },

      {
        type = "metric"
        x    = 0
        y    = 6
        width = 12
        height = 6
        properties = {
          metrics = [
            ["DevSecOps/Demo", "ErrorCount", { stat = "Sum", label = "Errors", color = "#d62728" }],
            [".", "WarningCount", { stat = "Sum", label = "Warnings", color = "#ff7f0e" }]
          ]
          period = 60
          stat   = "Sum"
          region = var.aws_region
          title  = "Application Errors & Warnings"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },

      {
        type = "metric"
        x    = 12
        y    = 6
        width = 12
        height = 6
        properties = {
          metrics = [
            ["DevSecOps/Demo", "SecurityEventCount", { stat = "Sum", label = "Security Events", color = "#d62728" }]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "Security Events"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },

      {
        type = "log"
        x    = 0
        y    = 12
        width = 24
        height = 6
        properties = {
          query   = "SOURCE '${aws_cloudwatch_log_group.app_logs.name}' | fields @timestamp, @message | filter @message like /ERROR/ | sort @timestamp desc | limit 20"
          region  = var.aws_region
          title   = "Recent Application Errors"
          stacked = false
        }
      },

      {
        type = "metric"
        x    = 0
        y    = 18
        width = 12
        height = 6
        properties = {
          metrics = [
            ["DevSecOps/Demo", "PipelineFailureCount", { stat = "Sum", label = "Pipeline Failures", color = "#d62728" }]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "CI/CD Pipeline Failures"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },

      {
        type = "alarm"
        x    = 12
        y    = 18
        width = 12
        height = 6
        properties = {
          alarms = [
            aws_cloudwatch_metric_alarm.high_cpu.arn,
            aws_cloudwatch_metric_alarm.high_memory.arn,
            aws_cloudwatch_metric_alarm.high_error_rate.arn,
            aws_cloudwatch_metric_alarm.security_events.arn,
            aws_cloudwatch_metric_alarm.missing_logs.arn,
            aws_cloudwatch_metric_alarm.pipeline_failure.arn
          ]
          title = "Alarm Status Overview"
        }
      },

      {
        type = "text"
        x    = 0
        y    = 24
        width = 24
        height = 2
        properties = {
          markdown = <<-EOT
            
            **Environment:** ${var.environment} | **Region:** ${var.aws_region} | **Updated:** Real-time
            
            This dashboard monitors:
            - System resources (CPU, Memory)
            - Application errors and warnings
            - Security events and threats
            - CI/CD pipeline status
            - Alarm health status
          EOT
        }
      }
    ]
  })
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "dashboard_url" {
  description = "URL to the CloudWatch dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}
