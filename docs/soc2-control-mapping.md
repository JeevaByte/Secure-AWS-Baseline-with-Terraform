# SOC 2 Control Mapping

This document maps implemented AWS technical controls to SOC 2 requirements.

## Overview
This mapping demonstrates how the technical controls in this repository address SOC 2 Trust Services Criteria (TSC).

## Control Mappings

### Common Criteria (CC)

#### CC6.1 - Logical and Physical Access Controls
**SOC 2 Requirement:** The entity implements logical access security software, infrastructure, and architectures over protected information assets to protect them from security events to meet the entity's objectives.

| Control Implementation | AWS Service | Terraform Module | Evidence Automation |
|------------------------|-------------|------------------|---------------------|
| IAM Password Policy | IAM | terraform/iam_hardening.tf | audit-evidence/upload_evidence.sh |
| MFA Enforcement | IAM | terraform/iam_hardening.tf | audit-evidence/upload_evidence.sh |
| Least Privilege Roles | IAM | modules/secure_baseline/main.tf | audit-evidence/upload_evidence.sh |
| Deny Insecure Actions | IAM | terraform/iam_hardening.tf | audit-evidence/upload_evidence.sh |

**Evidence:**
- IAM credential reports (automated collection)
- CloudTrail logs of access attempts
- Terraform state showing policy configurations

---

#### CC6.6 - Logical Access - Removal
**SOC 2 Requirement:** The entity discontinues logical and physical protections over physical assets only after the ability to read or recover data and software from those assets has been diminished and is no longer required to meet the entity's objectives.

| Control Implementation | AWS Service | Terraform Module | Evidence Automation |
|------------------------|-------------|------------------|---------------------|
| Access Key Rotation | IAM | terraform/iam_hardening.tf | audit-evidence/upload_evidence.sh |
| Automated Key Management | IAM | terraform/iam_hardening.tf | audit-evidence/upload_evidence.sh |

**Evidence:**
- IAM credential reports showing key age
- CloudTrail logs of key deletions

---

#### CC6.7 - Transmission of Data
**SOC 2 Requirement:** The entity restricts the transmission, movement, and removal of information to authorized internal and external users and processes, and protects it during transmission, movement, or removal to meet the entity's objectives.

| Control Implementation | AWS Service | Terraform Module | Evidence Automation |
|------------------------|-------------|------------------|---------------------|
| Encryption in Transit | VPC/TLS | modules/secure_baseline/main.tf | audit-evidence/upload_evidence.sh |
| Private Subnets Only | VPC | modules/secure_baseline/main.tf | audit-evidence/upload_evidence.sh |
| S3 Encryption | S3 | modules/secure_baseline/main.tf | audit-evidence/upload_evidence.sh |

**Evidence:**
- S3 bucket encryption configurations
- VPC configuration showing private subnets
- Terraform state files

---

#### CC7.2 - System Monitoring
**SOC 2 Requirement:** The entity monitors system components and the operation of those components for anomalies that are indicative of malicious acts, natural disasters, and errors affecting the entity's ability to meet its objectives; anomalies are analyzed to determine whether they represent security events.

| Control Implementation | AWS Service | Terraform Module | Evidence Automation |
|------------------------|-------------|------------------|---------------------|
| CloudTrail Logging | CloudTrail | terraform/iam_hardening.tf | audit-evidence/upload_evidence.sh |
| GuardDuty Monitoring | GuardDuty | logging-monitoring/ | audit-evidence/upload_evidence.sh |
| CloudWatch Logs | CloudWatch | logging-monitoring/ | audit-evidence/upload_evidence.sh |
| VPC Flow Logs | VPC | logging-monitoring/ | audit-evidence/upload_evidence.sh |

**Evidence:**
- CloudTrail event logs
- GuardDuty findings
- CloudWatch metrics and alarms
- VPC flow logs

---

#### CC8.1 - Change Management
**SOC 2 Requirement:** The entity authorizes, designs, develops or acquires, configures, documents, tests, approves, and implements changes to infrastructure, data, software, and procedures to meet its objectives.

| Control Implementation | AWS Service | Terraform Module | Evidence Automation |
|------------------------|-------------|------------------|---------------------|
| Infrastructure as Code | Terraform | All .tf files | cicd/deploy.yml |
| CI/CD Pipeline | GitHub Actions | cicd/deploy.yml | cicd/deploy.yml |
| Change Tracking | Git | N/A | cicd/deploy.yml |
| Automated Testing | Checkov | .github/workflows/terraform.yml | cicd/deploy.yml |

**Evidence:**
- Git commit history
- GitHub Actions workflow runs
- Terraform plan outputs
- Checkov scan results

---

### Confidentiality Criteria (C)

#### C1.1 - Confidential Information
**SOC 2 Requirement:** The entity identifies and maintains confidential information to meet the entity's objectives related to confidentiality.

| Control Implementation | AWS Service | Terraform Module | Evidence Automation |
|------------------------|-------------|------------------|---------------------|
| Data Classification | S3 Tags | modules/secure_baseline/main.tf | audit-evidence/upload_evidence.sh |
| Private Buckets | S3 | modules/secure_baseline/main.tf | audit-evidence/upload_evidence.sh |
| Encryption at Rest | S3/KMS | modules/secure_baseline/main.tf | audit-evidence/upload_evidence.sh |

**Evidence:**
- S3 bucket configurations
- Resource tags
- Encryption status reports

---

#### C1.2 - Disposal of Confidential Information
**SOC 2 Requirement:** The entity disposes of confidential information to meet the entity's objectives related to confidentiality.

| Control Implementation | AWS Service | Terraform Module | Evidence Automation |
|------------------------|-------------|------------------|---------------------|
| S3 Lifecycle Policies | S3 | modules/secure_baseline/main.tf | audit-evidence/upload_evidence.sh |
| Secure Deletion | S3 | terraform/iam_hardening.tf | audit-evidence/upload_evidence.sh |

**Evidence:**
- S3 lifecycle configurations
- CloudTrail logs of deletions

---

## Implementation Status

### Completed Controls ✓
- [x] IAM password policy enforcement
- [x] MFA requirement for sensitive actions
- [x] Deny insecure IAM actions
- [x] S3 encryption at rest
- [x] S3 public access blocking
- [x] Private VPC subnets only
- [x] Least privilege IAM roles
- [x] CloudTrail protection
- [x] Infrastructure as Code (Terraform)
- [x] Automated CI/CD pipeline
- [x] Audit evidence automation

### Planned Controls (Future Enhancements)
- [ ] AWS Config rule implementation
- [ ] GuardDuty detector deployment
- [ ] CloudWatch alarm configuration
- [ ] VPC Flow Logs enablement
- [ ] Centralized logging to S3
- [ ] KMS key management
- [ ] Secrets Manager integration
- [ ] AWS Security Hub integration
- [ ] SNS alerting for security events
- [ ] Automated compliance reporting

---

## Evidence Collection

The `audit-evidence/upload_evidence.sh` script automatically collects evidence for the following:

1. **CloudTrail Events** - API activity logs
2. **IAM Credential Reports** - User access and key rotation status
3. **S3 Security Configurations** - Encryption and public access settings
4. **VPC Flow Logs** - Network traffic logs
5. **GuardDuty Findings** - Threat detection results
6. **AWS Config Compliance** - Configuration compliance status

All evidence is stored with timestamps and retained for audit purposes.

---

## Audit Preparation

### For Auditors
1. Review this control mapping document
2. Examine Terraform modules in `/terraform` and `/modules` directories
3. Review CI/CD pipeline configurations in `/cicd` and `.github/workflows`
4. Examine collected evidence in GitHub Actions artifacts
5. Review Git commit history for change management evidence

### Evidence Locations
- **Terraform Plans:** GitHub Actions artifacts (90-day retention)
- **Audit Evidence:** GitHub Actions artifacts (7-year retention)
- **Security Scans:** GitHub Actions artifacts (90-day retention)
- **Change History:** Git repository commit log
- **Pipeline Execution:** GitHub Actions workflow run history

---

## Drata Integration

While this repository automates evidence collection, some evidence can be directly integrated with Drata:
- CloudTrail logs → Drata AWS integration
- IAM policies → Drata AWS integration
- GitHub Actions logs → Drata GitHub integration

For evidence types not automatically collected by Drata, use the provided `upload_evidence.sh` script and manually upload to Drata as needed.

---

## Maintenance

This document should be updated whenever:
- New controls are implemented
- Existing controls are modified
- Audit requirements change
- New evidence automation is added

Last Updated: 2025-10-25
