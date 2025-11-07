# Audit Evidence Automation

This directory contains scripts and tools for automating the collection of audit evidence for SOC 2 compliance.

## Overview

SOC 2 audits require extensive evidence of security controls and their effectiveness. This automation reduces manual effort and ensures consistent, timestamped evidence collection.

## Scripts

### `upload_evidence.sh`

Main evidence collection script that gathers:

1. **CloudTrail Events** - API activity and change logs
2. **IAM Credential Reports** - Access key age, MFA status, password age
3. **S3 Security Configurations** - Encryption settings, public access blocks
4. **VPC Flow Logs** - Network traffic analysis
5. **GuardDuty Findings** - Threat detection results
6. **AWS Config Compliance** - Configuration rule compliance status

### Usage

```bash
# Make script executable
chmod +x upload_evidence.sh

# Run evidence collection
./upload_evidence.sh

# Evidence is saved to ./evidence/ directory with timestamps
```

### Environment Variables

- `AWS_REGION` - AWS region to collect evidence from (default: us-east-1)
- `USER` - Username for filtering CloudTrail events (auto-detected)

### Prerequisites

1. AWS CLI installed and configured
2. AWS credentials with appropriate permissions:
   - `cloudtrail:LookupEvents`
   - `iam:GenerateCredentialReport`
   - `iam:GetCredentialReport`
   - `s3:ListBuckets`
   - `s3:GetBucketEncryption`
   - `s3:GetPublicAccessBlock`
   - `ec2:DescribeFlowLogs`
   - `guardduty:ListDetectors`
   - `guardduty:ListFindings`
   - `config:DescribeComplianceByConfigRule`

### CI/CD Integration

The script is automatically executed by the GitHub Actions workflow in `cicd/deploy.yml`:

```yaml
- name: Upload Evidence Script
  run: |
    chmod +x ./audit-evidence/upload_evidence.sh
    ./audit-evidence/upload_evidence.sh
```

Evidence is then uploaded to GitHub Actions artifacts with 7-year retention.

## Evidence Storage

### Local Development
- Evidence stored in `./evidence/` directory
- Files named with timestamps: `*_YYYYMMDD_HHMMSS.*`
- Summary file created: `evidence_summary_YYYYMMDD_HHMMSS.txt`

### CI/CD Pipeline
- Evidence uploaded as GitHub Actions artifacts
- Retention: 2555 days (~7 years) for SOC 2 compliance
- Accessible via GitHub Actions UI or API

## Evidence Files

| File Pattern | Description | SOC 2 Control |
|--------------|-------------|---------------|
| `cloudtrail_events_*.json` | API activity logs | CC7.2, CC8.1 |
| `iam_credential_report_*.csv` | User access and key status | CC6.1, CC6.6 |
| `s3_security_*.log` | S3 encryption and access | CC6.7, C1.1 |
| `vpc_flow_logs_*.json` | Network traffic logs | CC7.2 |
| `guardduty_findings_*.json` | Threat detection | CC7.2 |
| `config_compliance_*.json` | Config rule status | CC8.1 |
| `evidence_summary_*.txt` | Collection summary | All |

## Customization

### Adding New Evidence Types

To collect additional evidence:

1. Create a new function in `upload_evidence.sh`:

```bash
collect_new_evidence() {
    echo "Collecting new evidence type..."
    aws service-name describe-resource \
        --region "$AWS_REGION" \
        > "$EVIDENCE_DIR/new_evidence_${TIMESTAMP}.json"
}
```

2. Call the function in `main()`:

```bash
main() {
    check_aws_cli
    collect_cloudtrail_events
    collect_new_evidence  # Add here
    create_evidence_summary
}
```

### Filtering and Scoping

Modify the AWS CLI commands to filter evidence:

```bash
# Filter by time range
aws cloudtrail lookup-events \
    --start-time "2025-01-01T00:00:00Z" \
    --end-time "2025-12-31T23:59:59Z"

# Filter by event name
aws cloudtrail lookup-events \
    --lookup-attributes AttributeKey=EventName,AttributeValue=DeleteBucket
```

## Troubleshooting

### Permission Errors

If you encounter permission errors:

1. Check AWS IAM permissions for your credentials
2. Ensure the IAM role/user has required read permissions
3. Some evidence collection is optional and will skip if permissions are missing

### AWS CLI Not Found

Install AWS CLI:

```bash
# Linux/macOS
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify installation
aws --version
```

### Empty Evidence Files

Common causes:
- No resources exist yet (e.g., no GuardDuty detector)
- Time window too narrow
- Incorrect region specified

## Security Considerations

- Evidence files may contain sensitive information
- Store securely and limit access
- Encrypt evidence files in transit and at rest
- Follow your organization's data retention policies
- Review evidence before sharing with auditors

## Integration with Drata

While Drata can automatically collect some evidence via AWS integration, this script provides:
- Additional evidence types not auto-collected by Drata
- On-demand evidence collection
- Custom report formatting
- Evidence for manual review

To use with Drata:
1. Run the evidence collection script
2. Download evidence from GitHub Actions artifacts
3. Upload to Drata manually if needed

## Maintenance

Update the script when:
- AWS CLI commands change
- New evidence requirements are identified
- SOC 2 controls are updated
- Auditor feedback requires additional evidence

## Testing

Test the script in a non-production environment:

```bash
# Dry run (add echo before aws commands for testing)
./upload_evidence.sh

# Verify evidence files are created
ls -lh evidence/

# Check evidence summary
cat evidence/evidence_summary_*.txt
```

## Compliance

This automation supports:
- SOC 2 Type II audit preparation
- Continuous evidence collection
- Audit trail maintenance
- Regulatory compliance reporting

Evidence retention follows SOC 2 requirements for maintaining records for at least 7 years.
