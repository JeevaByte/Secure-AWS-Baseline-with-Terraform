# Terraform Modules for SOC 2 Compliance

This directory contains Terraform modules specifically designed for SOC 2 compliance and security hardening.

## Modules

### IAM Hardening (`iam_hardening.tf`)

Implements security policies and controls for Identity and Access Management:

**Features:**
- Deny insecure IAM actions without MFA
- Prevent CloudTrail disabling
- Enforce S3 encryption
- Block S3 public access modifications
- Strict password policy (14+ characters, complexity requirements, 90-day rotation)
- Audit logging role for centralized monitoring

**SOC 2 Controls Addressed:**
- CC6.1 - Logical and Physical Access Controls
- CC6.6 - Logical Access Removal
- CC7.2 - System Monitoring
- C1.1 - Confidential Information

## Usage

### Option 1: Deploy as Standalone Module

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Option 2: Reference from Root Module

Add to your root `main.tf`:

```hcl
module "iam_hardening" {
  source = "./terraform"
}
```

Then deploy:

```bash
terraform init
terraform plan
terraform apply
```

## Variables

The IAM hardening module uses default values and doesn't require variables. However, you can customize:

- Password policy requirements
- Log retention periods
- Resource naming conventions

## Outputs

The module doesn't export outputs by default but creates the following resources:
- IAM policy: `DenyInsecureActions`
- IAM role: `SOC2-AuditLogging-Role`
- IAM password policy with strict requirements

## Testing

Validate the Terraform configuration:

```bash
terraform validate
terraform fmt -check
```

Scan for security issues:

```bash
# Install checkov
pip install checkov

# Run security scan
checkov -d . --framework terraform
```

## Integration with CI/CD

This module is automatically deployed via the GitHub Actions workflow in `cicd/deploy.yml` when:
1. Changes are pushed to the main branch
2. The workflow is manually triggered
3. All validation and security checks pass

## Customization

To customize the security policies:

1. Edit `iam_hardening.tf`
2. Add additional Deny statements to the policy
3. Adjust password policy requirements
4. Add additional IAM roles for specific compliance needs

## Best Practices

- ✅ Review IAM policies regularly
- ✅ Enable MFA for all users
- ✅ Rotate access keys every 90 days
- ✅ Use IAM roles instead of long-term credentials
- ✅ Follow least privilege principle
- ✅ Monitor CloudTrail for unauthorized access attempts

## Compliance Notes

- Password policy enforces NIST 800-63B recommendations
- MFA requirement aligns with SOC 2 CC6.1
- CloudTrail protection supports CC7.2 and CC8.1
- Audit logging role enables evidence collection

## Dependencies

Required Terraform providers:
- `hashicorp/aws` >= 5.0

No external dependencies required.

## Maintenance

Review and update this module:
- When SOC 2 requirements change
- After security audits
- When AWS releases new security features
- Quarterly as part of compliance review

## Support

For issues or questions:
1. Check the SOC 2 control mapping in `/docs/soc2-control-mapping.md`
2. Review AWS IAM best practices documentation
3. Open an issue in the repository
