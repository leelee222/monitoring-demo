# **Monitoring Demo**

### Centralized Logging, Monitoring & Alerting for a Cloud-Native DevSecOps Environment

*A hands-on demonstration of observability using CloudWatch / Grafana / ELK + automated alerting pipelines.*

---

## **Project Overview**

This project implements a **complete monitoring and alerting workflow** as part of my Month 3 DevSecOps roadmap.

It covers:

* Centralized logging
* Performance & security monitoring
* Alerting on failures or security events
* Metrics dashboards
* Integration with CI/CD alerts

---

## **Tech Stack**

| Category         | Tools                           |
| ---------------- | ------------------------------- |
| Cloud Monitoring | AWS CloudWatch                  |
| Logging          | CloudWatch Logs, ELK            |
| Dashboards       | Grafana                         |
| CI/CD Alerts     | GitHub Actions notifications    |
| Languages        | Terraform, Bash, YAML           |

---

## **Features**

### **Centralized Logging**

* Application logs → CloudWatch Logs
* Pipeline logs → GitHub Actions
* Infrastructure logs → CloudWatch Metrics & Events

### **Monitoring Dashboards**

* Real-time metrics (CPU, memory, errors)
* Custom dashboard for app + pipeline
* Grafana visualization

### **Alerts & Notifications**

* Alerts on:

  * Failed deployments
  * High CPU
  * Security scan failures
  * Missing logs
* SNS / Email

### **CI/CD Integration**

* Pipeline triggers alerts for:

  * Failed builds
  * Failed security scans
  * Failed Terraform deploys

---

## **Project Structure**

```
monitoring-demo/
 ├── .github/
 │    ├── workflows
 │      └── monitoring-pipeline.yml
 ├── terraform/
 │    ├── cloudwatch.tf
 │    ├── dashboards.tf
 │    ├── alarms.tf
 │    └── provider.tf
 ├── app/
 │    ├── main.py
 │    └── logging.conf
 └── README.md
```

---

## **How It Works**

# **Centralized Logging Setup (CloudWatch)**

```hcl
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/devsecops/demo/app"
  retention_in_days = 7
}
```

The app logs are sent using AWS CLI or SDK.

---

# **CloudWatch Metrics + Custom Dashboard**

```hcl
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "devsecops-monitoring-demo"

  dashboard_body = jsonencode({
    widgets = [{
      type = "metric"
      properties = {
        metrics = [
          ["AWS/EC2", "CPUUtilization", "InstanceId", "i-xxxxxx"]
        ]
        title = "Instance CPU"
      }
    }]
  })
}
```

This creates my **custom monitoring dashboard**.

---

# **Alerts & Notification Rules**

Example: My CPU Alert

```hcl
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-alert"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 60
  statistic           = "Average"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}
```

SNS → Email

---

# **GitHub Actions Pipeline Alerts**

```yaml
- name: Notify on Failure
  if: failure()
  run: |
    aws sns publish --topic-arn ${{ secrets.SNS_TOPIC }} \
      --message "Pipeline failed: $GITHUB_WORKFLOW"
```

This sends an alert when:

- Security scan fails
- Deployment fails
- Test fails

---

## **Local Testing**

Simulate a log entry:

```bash
aws logs put-log-events \
  --log-group-name "/devsecops/demo/app" \
  --log-stream-name "stream1" \
  --log-events '[{"timestamp": 1699110000, "message": "Test log"}]'
```

---

## **Documentation**

In `docs/monitoring_workflow.md`

Explains:

* CloudWatch basics
* How logs flow from app → CloudWatch
* How alerts trigger
* Dashboard screenshots
* CI/CD integration

---

## **Connect With Me**

If you’re looking for someone who can automate, secure, monitor, and improve cloud systems - let’s talk

---
