# IAM Hardening for SOC 2 Compliance
# This module implements security policies to deny insecure actions

resource "aws_iam_policy" "deny_insecure_actions" {
  name        = "DenyInsecureActions"
  description = "Policy to deny insecure actions for SOC 2 compliance"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyInsecureIAMActions"
        Effect = "Deny"
        Action = [
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey",
          "iam:UpdateAccessKey"
        ]
        Resource = "*"
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      },
      {
        Sid    = "DenyCloudTrailDisabling"
        Effect = "Deny"
        Action = [
          "cloudtrail:DeleteTrail",
          "cloudtrail:StopLogging",
          "cloudtrail:UpdateTrail"
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyS3PublicAccess"
        Effect = "Deny"
        Action = [
          "s3:PutBucketPublicAccessBlock",
          "s3:DeleteBucketPublicAccessBlock"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-acl" = "private"
          }
        }
      },
      {
        Sid    = "DenyUnencryptedObjectUploads"
        Effect = "Deny"
        Action = [
          "s3:PutObject"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "AES256"
          }
        }
      }
    ]
  })

  tags = {
    Compliance = "SOC2"
    Purpose    = "Security-Hardening"
  }
}

# Password Policy for IAM Users
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention      = 24
}

# Role for SOC 2 audit logging
resource "aws_iam_role" "audit_logging" {
  name        = "SOC2-AuditLogging-Role"
  description = "Role for centralized audit logging and monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "cloudtrail.amazonaws.com",
            "config.amazonaws.com",
            "guardduty.amazonaws.com"
          ]
        }
      }
    ]
  })

  tags = {
    Compliance = "SOC2"
    Purpose    = "Audit-Logging"
  }
}

# Policy for audit logging role
resource "aws_iam_role_policy" "audit_logging_policy" {
  name = "SOC2-AuditLogging-Policy"
  role = aws_iam_role.audit_logging.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogsAccess"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Sid    = "S3AuditBucketAccess"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetBucketAcl"
        ]
        Resource = [
          "arn:aws:s3:::*-audit-logs/*",
          "arn:aws:s3:::*-audit-logs"
        ]
      }
    ]
  })
}
