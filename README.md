# AWS SOC 2 Compliance Automation

## Business Problem
Our company must ensure AWS infrastructure is audit-ready for SOC 2 Type II, requiring hands-on implementation and documentation of technical controls, security hardening, and traceable deployment automation.

## Solution
This repository contains:
- Hardened Terraform modules aligned with SOC 2 controls and AWS CIS benchmarks.
- Traceable, auditable CI/CD pipelines using GitHub Actions.
- Centralized logging and monitoring configurations (CloudWatch, GuardDuty, etc.).
- Scripts for automating audit evidence retrieval, especially where Drata integration is limited.
- Clear documentation for each implemented control and process.

## Project Structure
- `/terraform` - SOC 2 compliant Terraform modules (IAM hardening, etc.)
- `/cicd` - GitHub Actions workflow files for auditable deployments
- `/logging-monitoring` - Centralized logging/monitoring configs and scripts
- `/audit-evidence` - Scripts for evidence automation
- `/docs` - Implementation guides and control mappings
- `/modules` - Core secure baseline infrastructure modules (VPC, S3, IAM)

## Usage
- Clone this repo and follow documentation in `/docs` to implement and verify controls.
- Use provided pipelines and scripts to maintain compliance and readiness.
- Review the SOC 2 control mapping in `/docs/soc2-control-mapping.md` for audit requirements.

## Secure Baseline Infrastructure
The project provides a secure AWS baseline infrastructure using Terraform, including:
- Virtual Private Cloud (VPC) with private subnets only
- Encrypted S3 buckets with public access blocked
- IAM roles with least privilege principles
- Security controls aligned with AWS CIS benchmarks

## Git Large File Storage (LFS)
This project uses Git LFS to manage large files. To set up Git LFS, follow these steps:

1. Install Git LFS from [git-lfs.github.com](https://git-lfs.github.com).
2. Run the following command to initialize Git LFS in your repository:
   ```
   git lfs install
   ```
3. Track the large files by running:
   ```
   git lfs track "*.exe"
   ```
4. Commit the changes to the `.gitattributes` file:
   ```
   git add .gitattributes
   git commit -m "Track large files with Git LFS"
   ```

Make sure to push your changes to the repository after setting up Git LFS.
