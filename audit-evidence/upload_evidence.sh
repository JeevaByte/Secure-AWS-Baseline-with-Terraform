#!/bin/bash
# SOC 2 Audit Evidence Collection Script
# This script automates the collection of audit evidence from AWS services

set -e

# Configuration
EVIDENCE_DIR="audit-evidence/evidence"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
AWS_REGION="${AWS_REGION:-us-east-1}"

# Create evidence directory if it doesn't exist
mkdir -p "$EVIDENCE_DIR"

echo "======================================"
echo "SOC 2 Audit Evidence Collection"
echo "Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "======================================"

# Function to check if AWS CLI is available
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo "AWS CLI not found. Please install AWS CLI to collect evidence."
        exit 1
    fi
}

# Function to collect CloudTrail events
collect_cloudtrail_events() {
    echo "Collecting CloudTrail events..."
    aws cloudtrail lookup-events \
        --region "$AWS_REGION" \
        --max-results 50 \
        --lookup-attributes AttributeKey=Username,AttributeValue="${USER:-github-actions}" \
        > "$EVIDENCE_DIR/cloudtrail_events_${TIMESTAMP}.json" 2>&1 || \
        echo "CloudTrail collection skipped (may require additional permissions)"
}

# Function to collect IAM credential report
collect_iam_credential_report() {
    echo "Collecting IAM credential report..."
    aws iam generate-credential-report --region "$AWS_REGION" 2>&1 || true
    sleep 5
    aws iam get-credential-report \
        --region "$AWS_REGION" \
        --query 'Content' \
        --output text 2>&1 | base64 -d > "$EVIDENCE_DIR/iam_credential_report_${TIMESTAMP}.csv" || \
        echo "IAM credential report collection skipped (may require additional permissions)"
}

# Function to collect S3 bucket policies
collect_s3_bucket_info() {
    echo "Collecting S3 bucket security information..."
    aws s3api list-buckets \
        --region "$AWS_REGION" \
        --query 'Buckets[*].[Name]' \
        --output text 2>&1 | while read -r bucket; do
            if [ -n "$bucket" ]; then
                echo "Bucket: $bucket" >> "$EVIDENCE_DIR/s3_security_${TIMESTAMP}.log"
                aws s3api get-bucket-encryption --bucket "$bucket" --region "$AWS_REGION" >> "$EVIDENCE_DIR/s3_security_${TIMESTAMP}.log" 2>&1 || echo "  No encryption configured" >> "$EVIDENCE_DIR/s3_security_${TIMESTAMP}.log"
                aws s3api get-public-access-block --bucket "$bucket" --region "$AWS_REGION" >> "$EVIDENCE_DIR/s3_security_${TIMESTAMP}.log" 2>&1 || echo "  No public access block" >> "$EVIDENCE_DIR/s3_security_${TIMESTAMP}.log"
            fi
        done || echo "S3 security information collection skipped"
}

# Function to collect VPC flow logs status
collect_vpc_flow_logs() {
    echo "Collecting VPC flow logs status..."
    aws ec2 describe-flow-logs \
        --region "$AWS_REGION" \
        > "$EVIDENCE_DIR/vpc_flow_logs_${TIMESTAMP}.json" 2>&1 || \
        echo "VPC flow logs collection skipped"
}

# Function to collect GuardDuty findings (if enabled)
collect_guardduty_findings() {
    echo "Collecting GuardDuty findings..."
    # Get detector ID
    DETECTOR_ID=$(aws guardduty list-detectors --region "$AWS_REGION" --query 'DetectorIds[0]' --output text 2>&1)
    
    if [ -n "$DETECTOR_ID" ] && [ "$DETECTOR_ID" != "None" ]; then
        aws guardduty list-findings \
            --detector-id "$DETECTOR_ID" \
            --region "$AWS_REGION" \
            > "$EVIDENCE_DIR/guardduty_findings_${TIMESTAMP}.json" 2>&1 || true
    else
        echo "GuardDuty not enabled or accessible" >> "$EVIDENCE_DIR/guardduty_findings_${TIMESTAMP}.log"
    fi
}

# Function to collect Config compliance status
collect_config_compliance() {
    echo "Collecting AWS Config compliance status..."
    aws configservice describe-compliance-by-config-rule \
        --region "$AWS_REGION" \
        > "$EVIDENCE_DIR/config_compliance_${TIMESTAMP}.json" 2>&1 || \
        echo "Config compliance collection skipped"
}

# Function to create evidence summary
create_evidence_summary() {
    echo "Creating evidence summary..."
    cat > "$EVIDENCE_DIR/evidence_summary_${TIMESTAMP}.txt" <<EOF
SOC 2 Audit Evidence Summary
Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
Region: $AWS_REGION
Collector: ${USER:-github-actions}

Evidence Files Collected:
EOF
    ls -lh "$EVIDENCE_DIR"/*"${TIMESTAMP}"* >> "$EVIDENCE_DIR/evidence_summary_${TIMESTAMP}.txt" 2>&1 || true
}

# Main execution
main() {
    check_aws_cli
    
    echo "Starting evidence collection..."
    
    collect_cloudtrail_events
    collect_iam_credential_report
    collect_s3_bucket_info
    collect_vpc_flow_logs
    collect_guardduty_findings
    collect_config_compliance
    create_evidence_summary
    
    echo ""
    echo "======================================"
    echo "Evidence collection completed!"
    echo "Evidence stored in: $EVIDENCE_DIR"
    echo "======================================"
}

# Run main function
main
