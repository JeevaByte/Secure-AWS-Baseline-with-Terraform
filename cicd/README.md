# CI/CD Pipeline for SOC 2 Compliance

This directory contains GitHub Actions workflows for automated, traceable, and auditable infrastructure deployments.

## Overview

The CI/CD pipeline ensures that all infrastructure changes are:
- Automatically validated and tested
- Reviewed through pull requests
- Tracked with complete audit trails
- Compliant with SOC 2 requirements
- Securely deployed with evidence collection

## Workflows

### `deploy.yml`

Main deployment workflow that handles Terraform infrastructure deployment with comprehensive audit evidence collection.

**Triggers:**
- Push to `main` branch (automatic deployment)
- Manual workflow dispatch (on-demand deployment)

**Steps:**
1. **Code Checkout** - Retrieves latest code from repository
2. **Terraform Setup** - Installs specific Terraform version (1.7.0)
3. **AWS Authentication** - Configures AWS credentials from GitHub secrets
4. **Terraform Init** - Initializes Terraform working directory
5. **Terraform Validate** - Validates Terraform configuration syntax
6. **Terraform Plan** - Generates execution plan with detailed output
7. **Plan Artifact Upload** - Stores plan for audit trail (90-day retention)
8. **Terraform Apply** - Applies infrastructure changes (only on main branch)
9. **Evidence Collection** - Collects deployment metadata
10. **Evidence Script Execution** - Runs AWS evidence collection
11. **Evidence Upload** - Stores evidence artifacts (7-year retention)
12. **Security Scan** - Runs Checkov security analysis
13. **Security Results Upload** - Stores scan results (90-day retention)

## GitHub Secrets Required

Configure these secrets in your repository settings:

- `AWS_ACCESS_KEY_ID` - AWS access key for deployment
- `AWS_SECRET_ACCESS_KEY` - AWS secret key for deployment

## SOC 2 Compliance Features

### Change Management (CC8.1)
- All infrastructure changes tracked in Git
- Pull request reviews before deployment
- Automated testing and validation
- Complete deployment history in GitHub Actions

### Access Control (CC6.1)
- AWS credentials stored securely in GitHub Secrets
- Deployment limited to authorized workflows
- Audit trail of who triggered deployments

### System Monitoring (CC7.2)
- Security scanning with Checkov
- Deployment success/failure tracking
- Evidence collection for monitoring

## Artifact Retention

| Artifact Type | Retention Period | Purpose |
|---------------|------------------|---------|
| Terraform Plans | 90 days | Change review and audit |
| Audit Evidence | 2555 days (~7 years) | SOC 2 compliance |
| Security Scans | 90 days | Vulnerability tracking |

## Usage

### Automatic Deployment

Push to main branch:

```bash
git add .
git commit -m "Update infrastructure"
git push origin main
```

The workflow automatically runs and deploys changes.

### Manual Deployment

1. Go to Actions tab in GitHub
2. Select "Deploy to AWS" workflow
3. Click "Run workflow"
4. Select branch and confirm

### Reviewing Deployment Evidence

1. Go to Actions tab in GitHub
2. Select the workflow run
3. Download artifacts:
   - `terraform-plan` - Infrastructure changes
   - `audit-evidence` - Deployment evidence
   - `security-scan-results` - Security findings

## Integration with Existing Workflow

The repository also has `.github/workflows/terraform.yml` for CI validation:
- Runs on pull requests
- Validates Terraform syntax
- Runs security scans with Checkov
- Does NOT deploy infrastructure

This provides a safety net before changes reach main branch.

## Customization

### Adding Steps

Add custom validation or deployment steps:

```yaml
- name: Custom Validation
  run: |
    # Your custom commands here
    ./scripts/validate.sh
```

### Modifying Evidence Collection

Edit the evidence collection step:

```yaml
- name: Collect Custom Evidence
  run: |
    # Add custom evidence collection
    aws cloudtrail get-trail-status --name MyTrail > evidence/trail_status.json
```

### Environment-Specific Deployments

Add environment variables:

```yaml
- name: Terraform Apply
  run: terraform apply -auto-approve tfplan
  env:
    TF_VAR_environment: production
    TF_VAR_region: us-east-1
```

## Security Best Practices

### Credential Management
- ✅ Store credentials in GitHub Secrets
- ✅ Use IAM roles with least privilege
- ✅ Rotate credentials regularly
- ✅ Audit credential usage via CloudTrail

### Deployment Safety
- ✅ Require pull request reviews
- ✅ Run tests before deployment
- ✅ Use Terraform plan before apply
- ✅ Enable branch protection on main

### Evidence Collection
- ✅ Collect evidence for every deployment
- ✅ Store evidence securely with long retention
- ✅ Include deployment metadata (who, when, what)
- ✅ Archive Terraform plans for audit

## Troubleshooting

### Deployment Failures

Check the workflow logs:
1. Click on failed workflow run
2. Expand failed step
3. Review error messages

Common issues:
- AWS credential problems: Verify secrets are set correctly
- Terraform validation errors: Check Terraform syntax
- Resource conflicts: Review Terraform state
- Permission errors: Verify IAM permissions

### Evidence Collection Failures

The evidence collection is designed to continue even if some steps fail:
- Individual evidence collection errors are logged but don't fail the workflow
- Some evidence requires specific AWS permissions
- Missing resources (e.g., no GuardDuty detector) are handled gracefully

### Security Scan Failures

Checkov failures are informational only:
- Review findings in `checkov_results.json` artifact
- Address critical and high severity issues
- Update configurations or add exceptions as needed
- Re-run workflow after fixes

## Monitoring

### Workflow Runs
- View all runs in Actions tab
- Filter by status, branch, or event
- Review run duration and success rate

### Notifications
Configure GitHub notifications:
1. Go to repository settings
2. Navigate to Notifications
3. Enable workflow run notifications
4. Choose email or Slack integration

### Metrics
Track deployment metrics:
- Deployment frequency
- Success rate
- Time to deploy
- Security scan findings

## Compliance Documentation

For auditors, provide:
1. **Workflow YAML files** - Infrastructure as Code for deployments
2. **GitHub Actions history** - Complete deployment log
3. **Artifact downloads** - Terraform plans and evidence
4. **Branch protection settings** - Access control documentation
5. **Secret management** - How credentials are secured

## Testing

Test the workflow in a feature branch:

```bash
git checkout -b test-workflow
# Make changes to workflow
git add .github/workflows/deploy.yml
git commit -m "Test workflow changes"
git push origin test-workflow
```

Then manually trigger the workflow on the test branch.

## Maintenance

Review and update the workflow:
- When Terraform version updates
- When new security requirements emerge
- After SOC 2 audit feedback
- Quarterly as part of compliance review

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform Cloud Documentation](https://www.terraform.io/cloud-docs)
- [Checkov Security Scanning](https://www.checkov.io/)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
