# Secure AWS Baseline with Terraform

## Project Overview
This project provides a secure AWS baseline infrastructure using Terraform. It includes the creation of a Virtual Private Cloud (VPC) with private subnets, a secure S3 bucket, and an IAM role with least privilege.

## Directory Structure
- **main.tf**: Defines the main Terraform configuration, including the AWS provider and the secure baseline module.
- **variables.tf**: Contains the input variables for the Terraform configuration.
- **outputs.tf**: Specifies the outputs of the Terraform configuration.
- **modules/**: Contains reusable Terraform modules.
  - **secure_baseline/**: Module for creating the secure baseline infrastructure.
    - **main.tf**: Defines the resources for the secure baseline, including VPC, subnets, S3 bucket, and IAM role.
    - **variables.tf**: Contains the input variables for the secure baseline module.
    - **outputs.tf**: Specifies the outputs of the secure baseline module.
- **.github/workflows/**: Contains GitHub Actions workflows for CI/CD automation.
  - **terraform.yml**: Workflow for running Terraform commands and Checkov scans.

## Setup Instructions
1. Clone the repository:
   ```sh
   git clone <repository-url>
   cd secure-aws-baseline
   ```

2. Initialize Terraform:
   ```sh
   terraform init
   ```

3. Review and modify the input variables in `variables.tf` as needed.

4. Validate the Terraform configuration:
   ```sh
   terraform validate
   ```

5. Generate and review the execution plan:
   ```sh
   terraform plan
   ```

6. Apply the Terraform configuration to create the infrastructure:
   ```sh
   terraform apply
   ```

## Usage Guidelines
- Ensure you have the necessary AWS credentials configured in your environment.
- Modify the input variables in `variables.tf` to match your desired configuration.
- Use the provided GitHub Actions workflow to automate Terraform commands and security scans.

## CI/CD
The project includes a GitHub Actions workflow located in the `.github/workflows/terraform.yml` file. This workflow automates the following tasks:
- Initializing Terraform
- Validating the Terraform configuration
- Generating a Terraform plan
- Running Checkov scans for security compliance

## License
This project is licensed under the MIT License. See the LICENSE file for more details.