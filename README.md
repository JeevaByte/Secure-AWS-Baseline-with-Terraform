# Secure AWS Baseline with Terraform

## Project Overview
This project provides a secure AWS baseline infrastructure using Terraform. It includes the creation of a Virtual Private Cloud (VPC) with private subnets, security groups, and other necessary resources.

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
