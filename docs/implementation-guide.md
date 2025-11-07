# SOC 2 Implementation Guide

This guide provides step-by-step instructions for implementing and maintaining SOC 2 compliance using this repository.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Deploying Infrastructure](#deploying-infrastructure)
4. [Evidence Collection](#evidence-collection)
5. [Ongoing Maintenance](#ongoing-maintenance)
6. [Audit Preparation](#audit-preparation)

## Prerequisites

### Tools Required
- **Git** - Version control
- **Terraform** - Infrastructure as Code (v1.7.0 or later)
- **AWS CLI** - AWS command-line interface
- **GitHub Account** - For CI/CD and artifact storage

### AWS Account Setup
1. Create or use existing AWS account
2. Set up IAM user or role for Terraform with appropriate permissions
3. Configure AWS credentials locally:
   ```bash
   aws configure
   ```

### GitHub Repository Setup
1. Fork or clone this repository
2. Configure GitHub Secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
3. Enable GitHub Actions in repository settings

## Initial Setup

### 1. Clone Repository

```bash
git clone https://github.com/YOUR-ORG/Secure-AWS-Baseline-with-Terraform.git
cd Secure-AWS-Baseline-with-Terraform
```

### 2. Review Configuration

Review and customize variables:

```bash
# Edit variables.tf
vim variables.tf

# Set your environment name
# Set your VPC CIDR block
# Review other configurations
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Validate Configuration

```bash
terraform validate
terraform fmt -check
```

## Deploying Infrastructure

### Local Deployment

For testing in development:

```bash
# Review what will be created
terraform plan

# Apply changes
terraform apply

# Review outputs
terraform output
```

### Production Deployment via CI/CD

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/add-security-control
   ```

2. **Make Changes**
   - Update Terraform configurations
   - Test locally
   - Commit changes

3. **Create Pull Request**
   ```bash
   git add .
   git commit -m "Add new security control"
   git push origin feature/add-security-control
   ```
   - Open PR in GitHub
   - Review automated checks
   - Get approval from team

4. **Merge to Main**
   - Merge PR after approval
   - Automatic deployment triggers
   - Monitor GitHub Actions workflow

### Deployment Verification

After deployment:

1. **Check GitHub Actions**
   - Verify workflow completed successfully
   - Review deployment logs
   - Check for errors

2. **Verify AWS Resources**
   ```bash
   # List created resources
   terraform state list
   
   # Inspect specific resources
   terraform state show aws_vpc.main
   ```

3. **Download Evidence**
   - Go to GitHub Actions workflow run
   - Download audit evidence artifacts
   - Review evidence files

## Evidence Collection

### Automated Collection (via CI/CD)

Evidence is automatically collected on every deployment:
- Deployment metadata
- AWS resource configurations
- Security scan results

Artifacts are retained for 7 years to meet SOC 2 requirements.

### Manual Collection

For ad-hoc evidence collection:

```bash
cd audit-evidence
chmod +x upload_evidence.sh
./upload_evidence.sh
```

Evidence is saved to `audit-evidence/evidence/` directory.

### Evidence Types Collected

1. **CloudTrail Events** - API activity logs
2. **IAM Credential Report** - User and key status
3. **S3 Security Settings** - Encryption and access controls
4. **VPC Flow Logs** - Network traffic (if enabled)
5. **GuardDuty Findings** - Threat detection (if enabled)
6. **Config Compliance** - Configuration compliance status

### Reviewing Evidence

```bash
cd audit-evidence/evidence/

# List collected evidence
ls -lh

# Review summary
cat evidence_summary_*.txt

# Examine specific evidence
cat cloudtrail_events_*.json
cat iam_credential_report_*.csv
```

## Ongoing Maintenance

### Daily Tasks
- Monitor GitHub Actions for deployment failures
- Review security alerts from GuardDuty (if enabled)
- Check CloudWatch alarms

### Weekly Tasks
- Review IAM credential reports
- Check for unauthorized access attempts in CloudTrail
- Review open pull requests

### Monthly Tasks
- Rotate AWS access keys
- Review and update security policies
- Run comprehensive security scans
- Review CloudWatch metrics and alarms

### Quarterly Tasks
- Conduct SOC 2 control review
- Update documentation
- Review and update Terraform modules
- Audit IAM users and permissions
- Review evidence retention and storage

## Audit Preparation

### Pre-Audit Checklist

- [ ] All Terraform configurations are documented
- [ ] All CI/CD workflows are operational
- [ ] Evidence collection is working properly
- [ ] GitHub Actions artifacts are retained
- [ ] CloudTrail is enabled and logging
- [ ] IAM policies are up to date
- [ ] S3 buckets are encrypted and private
- [ ] VPC security is properly configured
- [ ] Security scans are passing or issues documented
- [ ] Control mapping document is current

### Evidence Package for Auditors

Prepare the following:

1. **Documentation**
   - `/docs/soc2-control-mapping.md`
   - This implementation guide
   - README files from all directories

2. **Terraform Configurations**
   - All `.tf` files
   - Terraform state (sanitized if needed)
   - Terraform plan outputs

3. **CI/CD Evidence**
   - GitHub Actions workflow files
   - Workflow run history (screenshots)
   - Artifact downloads for review period

4. **AWS Evidence**
   - Collected evidence from audit-evidence scripts
   - CloudTrail logs
   - IAM credential reports
   - Security scan results

5. **Access Control Evidence**
   - GitHub user permissions
   - AWS IAM policies and roles
   - MFA enforcement documentation

### Auditor Access

Provide auditors with:

1. **Read-only GitHub access** to repository
2. **Links to workflow runs** during audit period
3. **Downloaded evidence artifacts** as needed
4. **Documentation package** in PDF format

### Common Auditor Questions

**Q: How do you ensure infrastructure changes are authorized?**
A: All changes go through pull request review process with required approvals. See `.github/workflows/` for automated checks.

**Q: How do you track who made what changes?**
A: Git commit history provides complete audit trail. GitHub Actions logs show deployment actor and timestamp.

**Q: How is access to AWS resources controlled?**
A: IAM policies enforce least privilege. See `terraform/iam_hardening.tf` for deny policies. CloudTrail logs all access.

**Q: How often is evidence collected?**
A: Evidence is automatically collected on every deployment and retained for 7 years in GitHub Actions artifacts.

**Q: How do you detect security threats?**
A: Multiple layers: Checkov scans code, CloudTrail logs activity, GuardDuty detects threats (when enabled), CloudWatch alarms on suspicious activity.

## Troubleshooting

### Terraform Errors

**Error: Resource already exists**
```bash
# Import existing resource
terraform import aws_s3_bucket.secure_bucket bucket-name
```

**Error: State lock**
```bash
# If state is stuck, force unlock (use cautiously)
terraform force-unlock LOCK_ID
```

### AWS Permission Issues

**Error: Access Denied**
1. Check IAM user/role permissions
2. Verify AWS credentials are correctly configured
3. Review CloudTrail for denied API calls

### Evidence Collection Failures

**Script exits with errors**
1. Check AWS CLI installation: `aws --version`
2. Verify AWS credentials: `aws sts get-caller-identity`
3. Review script permissions: `chmod +x upload_evidence.sh`
4. Check IAM permissions for evidence collection APIs

### CI/CD Issues

**Workflow fails**
1. Check GitHub Secrets are configured
2. Review workflow logs in Actions tab
3. Verify Terraform syntax locally
4. Check AWS resource limits

## Security Incidents

If a security incident occurs:

1. **Immediate Response**
   - Document the incident
   - Collect evidence immediately
   - Review CloudTrail logs
   - Check GuardDuty findings

2. **Investigation**
   - Run evidence collection script
   - Review IAM credential report
   - Check for unauthorized changes in Terraform state
   - Review recent deployments in GitHub Actions

3. **Remediation**
   - Rotate compromised credentials
   - Update security policies
   - Deploy fixes via CI/CD
   - Document lessons learned

4. **Evidence Preservation**
   - Save all logs and evidence
   - Document timeline
   - Prepare incident report
   - Notify auditors if needed

## Best Practices

### Infrastructure as Code
- Keep Terraform configurations modular
- Use version control for all changes
- Document resources with tags
- Follow naming conventions

### Access Management
- Enable MFA for all users
- Rotate credentials regularly
- Use IAM roles instead of keys when possible
- Follow least privilege principle

### Change Management
- All changes through pull requests
- Require code reviews
- Automate testing and validation
- Document major changes

### Evidence and Audit
- Collect evidence continuously
- Retain evidence for required periods
- Automate collection where possible
- Regular evidence reviews

### Security
- Regular security scans
- Monitor CloudWatch alarms
- Review GuardDuty findings
- Keep software up to date
- Respond to security alerts promptly

## Additional Resources

### Internal Documentation
- `/docs/soc2-control-mapping.md` - Control mapping
- `/terraform/README.md` - Terraform modules documentation
- `/cicd/README.md` - CI/CD pipeline documentation
- `/audit-evidence/README.md` - Evidence collection guide

### External Resources
- [SOC 2 Compliance Guide](https://www.aicpa.org/interestareas/frc/assuranceadvisoryservices/sorhome.html)
- [AWS Security Best Practices](https://aws.amazon.com/security/best-practices/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## Support and Updates

### Getting Help
1. Review documentation in `/docs` directory
2. Check GitHub Issues for similar problems
3. Consult AWS documentation
4. Contact your security team

### Staying Current
- Subscribe to AWS Security Bulletins
- Monitor Terraform provider updates
- Review GitHub Dependabot alerts
- Follow SOC 2 framework updates

### Contributing Improvements
1. Create issue describing improvement
2. Create feature branch
3. Implement and test changes
4. Submit pull request
5. Update documentation

---

**Document Version:** 1.0  
**Last Updated:** 2025-10-25  
**Maintained By:** Security & Compliance Team
