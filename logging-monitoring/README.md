# Logging and Monitoring Configuration

This directory contains Terraform configurations for centralized logging and monitoring to support SOC 2 compliance.

## Components

### CloudWatch
- **Log Groups**: Separate log groups for application and security logs with appropriate retention periods
- **Alarms**: Security-focused alarms for unauthorized API calls and root account usage
- **Metrics**: Custom metrics for tracking security events

### VPC Flow Logs (Optional)
VPC Flow Logs configuration is included but commented out. Enable by:
1. Uncommenting the resources in `cloudwatch.tf`
2. Providing the VPC ID variable
3. Applying the Terraform configuration

### GuardDuty (Optional)
GuardDuty threat detection configuration is included but commented out to avoid unnecessary costs. Enable for production environments by:
1. Uncommenting the GuardDuty resources in `cloudwatch.tf`
2. Applying the Terraform configuration
3. Configuring SNS notifications for findings

## Retention Periods

All retention periods are configured for SOC 2 compliance:
- **Security Logs**: 7 years (~2555 days)
- **Application Logs**: 1 year (365 days)
- **VPC Flow Logs**: 1 year (365 days)

## Usage

To deploy these monitoring resources:

```bash
terraform init
terraform plan -target=module.logging_monitoring
terraform apply -target=module.logging_monitoring
```

## Integration with Evidence Collection

The `audit-evidence/upload_evidence.sh` script automatically collects:
- CloudWatch log events
- GuardDuty findings (if enabled)
- VPC Flow Logs status (if enabled)

## Alerting

Configure SNS topics and subscriptions to receive alerts for:
- Unauthorized API calls
- Root account usage
- GuardDuty findings
- Config compliance changes

Example SNS integration (add to cloudwatch.tf):

```hcl
resource "aws_sns_topic" "security_alerts" {
  name = "soc2-security-alerts"
  
  tags = {
    Compliance = "SOC2"
    Purpose    = "Security-Alerting"
  }
}

resource "aws_sns_topic_subscription" "security_email" {
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = "security-team@example.com"
}
```

## Cost Considerations

- CloudWatch Logs: Charged based on data ingestion and storage
- VPC Flow Logs: Additional CloudWatch costs for log storage
- GuardDuty: Monthly cost per account plus per-GB of analyzed logs
- CloudWatch Alarms: Free tier includes 10 alarms, then $0.10/alarm/month

Review AWS pricing before enabling optional features in production.
