# Quick Reference Guide

Quick reference for common tasks and information about the SOC 2 compliance automation repository.

## Quick Links

| Document | Purpose |
|----------|---------|
| [README.md](../README.md) | Repository introduction and overview |
| [OVERVIEW.md](OVERVIEW.md) | Complete repository structure and components |
| [implementation-guide.md](implementation-guide.md) | Step-by-step deployment and maintenance |
| [soc2-control-mapping.md](soc2-control-mapping.md) | SOC 2 controls to implementation mapping |

## Common Commands

### Deploy Infrastructure

```bash
# Local deployment
terraform init
terraform plan
terraform apply

# Via CI/CD (automatic on merge to main)
git push origin main
```

### Collect Evidence

```bash
# Make script executable (first time only)
chmod +x audit-evidence/upload_evidence.sh

# Run evidence collection
./audit-evidence/upload_evidence.sh

# View collected evidence
ls -lh audit-evidence/evidence/
```

### Validate Changes

```bash
# Validate Terraform syntax
terraform validate

# Format Terraform files
terraform fmt -recursive

# Run security scan (requires checkov)
pip install checkov
checkov -d . --framework terraform
```

### Review Audit Trail

```bash
# View deployment history
git log --oneline --graph

# View file changes
git diff HEAD~1 HEAD

# View GitHub Actions runs
# Go to: https://github.com/YOUR-ORG/REPO/actions
```

## Directory Quick Reference

| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| `/terraform` | SOC 2 hardening modules | `iam_hardening.tf` |
| `/cicd` | Deployment workflows | `deploy.yml` |
| `/logging-monitoring` | CloudWatch configs | `cloudwatch.tf` |
| `/audit-evidence` | Evidence automation | `upload_evidence.sh` |
| `/docs` | All documentation | This file! |
| `/modules/secure_baseline` | Core infrastructure | `main.tf` |

## File Descriptions

### Terraform Files
- **main.tf** - Root module configuration
- **variables.tf** - Input variables
- **outputs.tf** - Output values
- **terraform/iam_hardening.tf** - IAM security policies
- **logging-monitoring/cloudwatch.tf** - Logging and monitoring
- **modules/secure_baseline/main.tf** - VPC, S3, IAM baseline

### CI/CD Files
- **.github/workflows/terraform.yml** - PR validation workflow
- **cicd/deploy.yml** - Main deployment workflow

### Scripts
- **audit-evidence/upload_evidence.sh** - Evidence collection script

### Documentation
- **README.md** - Main repository documentation
- **docs/OVERVIEW.md** - Complete repository overview
- **docs/implementation-guide.md** - Implementation steps
- **docs/soc2-control-mapping.md** - SOC 2 control mapping

## SOC 2 Controls at a Glance

| Control | What It Covers | Where Implemented |
|---------|----------------|-------------------|
| CC6.1 | Access Controls | `terraform/iam_hardening.tf` |
| CC6.6 | Access Removal | `terraform/iam_hardening.tf` |
| CC6.7 | Data Transmission | `modules/secure_baseline/main.tf` |
| CC7.2 | System Monitoring | `logging-monitoring/cloudwatch.tf` |
| CC8.1 | Change Management | `.github/workflows/`, `cicd/` |
| C1.1 | Confidential Info | `modules/secure_baseline/main.tf` |

## Evidence Collection

### What's Collected
1. CloudTrail API events
2. IAM credential reports
3. S3 security settings
4. VPC Flow Logs status
5. GuardDuty findings
6. AWS Config compliance

### Where Evidence Is Stored
- **Local**: `audit-evidence/evidence/` (not committed)
- **CI/CD**: GitHub Actions artifacts (7-year retention)

### How to Access Evidence
1. Go to GitHub Actions
2. Select workflow run
3. Download artifacts:
   - `terraform-plan` (90 days)
   - `audit-evidence` (7 years)
   - `security-scan-results` (90 days)

## Workflow Overview

```
┌─────────────┐
│ Developer   │
│ Makes Change│
└──────┬──────┘
       │
       v
┌─────────────┐
│Create Branch│
│& Pull Req   │
└──────┬──────┘
       │
       v
┌─────────────┐
│ CI Validates│
│ (terraform  │
│  validate & │
│  checkov)   │
└──────┬──────┘
       │
       v
┌─────────────┐
│Team Reviews │
│& Approves   │
└──────┬──────┘
       │
       v
┌─────────────┐
│Merge to Main│
└──────┬──────┘
       │
       v
┌─────────────┐
│Auto Deploy  │
│(terraform   │
│ apply)      │
└──────┬──────┘
       │
       v
┌─────────────┐
│Collect      │
│Evidence     │
└──────┬──────┘
       │
       v
┌─────────────┐
│Upload to    │
│GitHub       │
│Artifacts    │
└─────────────┘
```

## Troubleshooting Quick Tips

### Terraform Errors
- **"Resource already exists"** → Use `terraform import`
- **"State locked"** → Wait or use `terraform force-unlock` (carefully)
- **"Invalid syntax"** → Run `terraform validate`

### AWS Errors
- **"Access Denied"** → Check IAM permissions
- **"Credentials not found"** → Run `aws configure`
- **"Region error"** → Set AWS_REGION environment variable

### CI/CD Errors
- **Workflow fails** → Check GitHub Secrets are set
- **Plan fails** → Review Terraform syntax locally
- **Apply fails** → Check AWS resource limits

### Evidence Collection
- **Script fails** → Check AWS CLI installation
- **Empty files** → Verify IAM permissions
- **Permission denied** → Make script executable with `chmod +x`

## Security Checklist

Before deploying to production:

- [ ] AWS credentials configured securely
- [ ] GitHub Secrets set (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
- [ ] MFA enabled for AWS root account
- [ ] Branch protection enabled on main branch
- [ ] Pull request reviews required
- [ ] All security scans passing
- [ ] CloudTrail enabled
- [ ] IAM password policy enforced
- [ ] S3 buckets encrypted
- [ ] VPC using private subnets only

## Audit Preparation Checklist

When preparing for audit:

- [ ] Collect latest evidence with script
- [ ] Download GitHub Actions artifacts
- [ ] Export Git commit history
- [ ] Document any exceptions or deviations
- [ ] Review control mapping document
- [ ] Prepare infrastructure diagrams
- [ ] List all deployed resources
- [ ] Gather security scan results
- [ ] Document incident response procedures
- [ ] Review access logs

## Important Notes

⚠️ **Do not commit**:
- AWS credentials
- Evidence files (auto-excluded in .gitignore)
- Terraform state files (auto-excluded)
- Sensitive configuration data

✅ **Do commit**:
- Terraform configurations
- Documentation updates
- CI/CD workflow changes
- Scripts and automation

## Need Help?

1. **For implementation questions**: Read `/docs/implementation-guide.md`
2. **For SOC 2 questions**: Check `/docs/soc2-control-mapping.md`
3. **For technical issues**: Review component README files
4. **For security concerns**: Contact security team immediately

## Useful AWS CLI Commands

```bash
# Check current identity
aws sts get-caller-identity

# List all S3 buckets
aws s3 ls

# Check IAM password policy
aws iam get-account-password-policy

# List CloudTrail trails
aws cloudtrail describe-trails

# Get recent CloudTrail events
aws cloudtrail lookup-events --max-results 10
```

## GitHub Actions Quick Access

- **All workflows**: `https://github.com/YOUR-ORG/REPO/actions`
- **Workflow runs**: Click on specific workflow → View runs
- **Download artifacts**: Workflow run → Artifacts section
- **View logs**: Workflow run → Click on job → Expand steps

## Maintenance Schedule

| Frequency | Tasks |
|-----------|-------|
| Daily | Monitor workflows, check alerts |
| Weekly | Review IAM reports, check CloudTrail |
| Monthly | Rotate credentials, update policies |
| Quarterly | SOC 2 review, update docs |

## Version Information

- **Terraform**: 1.7.0+
- **AWS Provider**: Latest stable
- **Repository Version**: 1.0

---

**Quick Tip**: Bookmark this page for easy reference!

**Last Updated**: 2025-10-25
