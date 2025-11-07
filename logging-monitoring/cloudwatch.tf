# Centralized Logging and Monitoring for SOC 2 Compliance

This module provides CloudWatch logging, GuardDuty, and VPC Flow Logs configurations.

## CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "/aws/soc2/application-logs"
  retention_in_days = 365  # 1 year retention for SOC 2

  tags = {
    Compliance = "SOC2"
    Purpose    = "Application-Logging"
  }
}

resource "aws_cloudwatch_log_group" "security_logs" {
  name              = "/aws/soc2/security-logs"
  retention_in_days = 2555  # ~7 years retention for SOC 2

  tags = {
    Compliance = "SOC2"
    Purpose    = "Security-Logging"
  }
}

## CloudWatch Alarms for Security Events
resource "aws_cloudwatch_metric_alarm" "unauthorized_api_calls" {
  alarm_name          = "unauthorized-api-calls-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnauthorizedAPICalls"
  namespace           = "CloudTrailMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Alarm when unauthorized API calls are detected"
  treat_missing_data  = "notBreaching"

  tags = {
    Compliance = "SOC2"
    Purpose    = "Security-Alerting"
  }
}

resource "aws_cloudwatch_metric_alarm" "root_account_usage" {
  alarm_name          = "root-account-usage-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "RootAccountUsage"
  namespace           = "CloudTrailMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Alarm when root account is used"
  treat_missing_data  = "notBreaching"

  tags = {
    Compliance = "SOC2"
    Purpose    = "Security-Alerting"
  }
}

## VPC Flow Logs (commented out - requires VPC ID to be passed in)
# Uncomment and configure when deploying with existing VPC

# resource "aws_flow_log" "main" {
#   vpc_id          = var.vpc_id
#   traffic_type    = "ALL"
#   iam_role_arn    = aws_iam_role.flow_logs.arn
#   log_destination = aws_cloudwatch_log_group.flow_logs.arn
# 
#   tags = {
#     Compliance = "SOC2"
#     Purpose    = "Network-Monitoring"
#   }
# }

# resource "aws_cloudwatch_log_group" "flow_logs" {
#   name              = "/aws/soc2/vpc-flow-logs"
#   retention_in_days = 365
# 
#   tags = {
#     Compliance = "SOC2"
#     Purpose    = "Network-Monitoring"
#   }
# }

# resource "aws_iam_role" "flow_logs" {
#   name = "vpc-flow-logs-role"
# 
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "vpc-flow-logs.amazonaws.com"
#         }
#       }
#     ]
#   })
# 
#   tags = {
#     Compliance = "SOC2"
#     Purpose    = "Network-Monitoring"
#   }
# }

# resource "aws_iam_role_policy" "flow_logs" {
#   name = "vpc-flow-logs-policy"
#   role = aws_iam_role.flow_logs.id
# 
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents",
#           "logs:DescribeLogGroups",
#           "logs:DescribeLogStreams"
#         ]
#         Effect   = "Allow"
#         Resource = "*"
#       }
#     ]
#   })
# }

## GuardDuty Detector (commented out - can incur costs)
# Uncomment to enable GuardDuty threat detection

# resource "aws_guardduty_detector" "main" {
#   enable = true
# 
#   finding_publishing_frequency = "FIFTEEN_MINUTES"
# 
#   tags = {
#     Compliance = "SOC2"
#     Purpose    = "Threat-Detection"
#   }
# }

# resource "aws_guardduty_detector" "main" {
#   enable = true
#   
#   datasources {
#     s3_logs {
#       enable = true
#     }
#     kubernetes {
#       audit_logs {
#         enable = true
#       }
#     }
#   }
# 
#   tags = {
#     Compliance = "SOC2"
#     Purpose    = "Threat-Detection"
#   }
# }
