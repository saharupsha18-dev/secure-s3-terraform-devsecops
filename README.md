# Secure AWS S3 Infrastructure with Terraform and DevSecOps

## 1. Project Overview

This project demonstrates how to build and manage secure AWS S3 infrastructure using Terraform and DevSecOps practices.

It uses **Terraform modules** to create separate S3 buckets for Development, Testing, and Production environments.

Instead of using a real AWS account, the project uses **Floci**, a local AWS cloud emulator running inside Docker. This allows AWS infrastructure to be developed and tested locally.

The project also includes a Jenkins CI/CD pipeline to automate Terraform validation, security scanning, infrastructure planning, and deployment with manual approval.

### Project Objectives

- Provision S3 infrastructure using Terraform.
- Create separate S3 buckets for Dev, Test, and Production.
- Reuse Terraform modules to avoid duplicate code.
- Apply security settings to S3 buckets.
- Test AWS S3 services locally using Floci.
- Store infrastructure code in GitHub.
- Automate infrastructure checks using Jenkins.
- Scan Terraform code for security issues using Checkov.
- Require manual approval before infrastructure deployment.
- Manage infrastructure changes using Terraform state.

---

## 2. Technology Stack

| Technology | Purpose |
|---|---|
| Terraform | Infrastructure as Code (IaC) |
| AWS S3 | Object storage service |
| Floci | Local AWS service emulator |
| Docker | Runs Floci and Jenkins containers |
| Jenkins | CI/CD pipeline automation |
| Checkov | Infrastructure security scanning |
| Git | Source code version control |
| GitHub | Remote source code repository |
| AWS CLI | Verify S3 resources and configurations |
| VS Code | Development environment |
| PowerShell | Run local commands on Windows |

---

## 3. Project Architecture

The project follows this workflow:

```text
Developer
    |
    v
VS Code
    |
    v
Terraform Configuration
    |
    v
Git / GitHub
    |
    v
Jenkins CI/CD Pipeline
    |
    +--> Checkout Source Code
    |
    +--> Terraform Format Check
    |
    +--> Terraform Initialization
    |
    +--> Terraform Validation
    |
    +--> Checkov Security Scan
    |
    +--> Terraform Plan
    |
    +--> Manual Approval
    |
    +--> Terraform Apply
    |
    v
Floci (Local AWS Emulator)
    |
    +--> Development S3 Bucket
    |
    +--> Testing S3 Bucket
    |
    +--> Production S3 Bucket
```

### Docker Network Architecture

Floci and Jenkins run inside separate Docker containers connected through a shared Docker network.

```text
Docker Desktop
    |
    +--> terraform-lab-net
             |
             +--> floci
             |      Port: 4566
             |
             +--> Jenkins_custom
                    |
                    +--> Terraform
                    +--> Checkov
```

The endpoint used depends on where Terraform runs.

| Execution Environment | S3 Endpoint |
|---|---|
| Windows / VS Code | `http://localhost:4566` |
| Jenkins Docker container | `http://floci:4566` |

This allows Jenkins to communicate with Floci using Docker container networking.

---

## 4. Project Directory Structure

```text
secure-s3-project/
|
|-- .gitignore
|-- .terraform.lock.hcl
|
|-- provider.tf
|-- variables.tf
|-- terraform.tfvars
|-- jenkins.tfvars
|-- main.tf
|-- outputs.tf
|-- locals.tf
|
|-- Jenkinsfile
|-- README.md
|
|-- modules/
|   |
|   |-- s3-bucket/
|       |-- main.tf
|       |-- variables.tf
|       |-- outputs.tf
|
|-- docker/
    |-- README.md
```

### File Descriptions

| File | Purpose |
|---|---|
| `provider.tf` | Configures the AWS Terraform provider and Floci endpoint |
| `variables.tf` | Declares root input variables |
| `terraform.tfvars` | Contains local environment variable values |
| `jenkins.tfvars` | Contains Jenkins-specific endpoint configuration |
| `main.tf` | Calls the reusable S3 module for three environments |
| `outputs.tf` | Displays bucket names and ARNs |
| `locals.tf` | Reserved for reusable local values |
| `modules/s3-bucket/main.tf` | Defines S3 resources and security settings |
| `modules/s3-bucket/variables.tf` | Defines module input variables |
| `modules/s3-bucket/outputs.tf` | Exports bucket information |
| `Jenkinsfile` | Defines the Jenkins CI/CD pipeline |
| `.gitignore` | Prevents local and sensitive files from being committed |
| `.terraform.lock.hcl` | Records selected provider versions |
| `docker/README.md` | Documents Docker networking and setup |

**Note:** The local `.tfvars` files are excluded from Git and must be created separately when setting up the project.

---

## 5. Terraform Infrastructure

The project creates three independent S3 buckets using a single reusable Terraform module.

### Environment Configuration

| Environment | S3 Bucket |
|---|---|
| Development | `secure-s3-project-dev-202611` |
| Testing | `secure-s3-project-test-202611` |
| Production | `secure-s3-project-prod-202611` |

Each environment has its own bucket name, tags, versioning setting, and HTTPS enforcement setting.

### Reusable Terraform Module

The module accepts these inputs:

- `bucket_name`
- `environment`
- `enable_versioning`
- `enforce_secure_transport`

The root `main.tf` calls the same module three times.

This avoids writing the same S3 infrastructure code separately for each environment.

---

## 6. S3 Security Features

### 6.1 Server-Side Encryption

All S3 buckets use server-side encryption with the AES256 algorithm (SSE-S3).

This configures encryption for objects stored in the bucket.

### 6.2 Bucket Versioning

Versioning is enabled for Development, Testing, and Production.

Versioning allows multiple versions of an object to be maintained, helping recover earlier versions when objects are changed or deleted.

### 6.3 Block Public Access

All four S3 public access block settings are enabled:

```text
BlockPublicAcls       = true
IgnorePublicAcls      = true
BlockPublicPolicy     = true
RestrictPublicBuckets = true
```

These settings help prevent unintended public access.

### 6.4 Object Ownership

The buckets use:

```text
BucketOwnerEnforced
```

This disables ACL-based permissions and makes the bucket owner the owner of objects stored in the bucket.

### 6.5 Lifecycle Management

A lifecycle rule is configured to abort incomplete multipart uploads after seven days.

Rule ID:

```text
abort-incomplete-uploads
```

This helps clean up unused multipart upload data without deleting successfully uploaded objects.

### 6.6 HTTPS Enforcement

The Terraform module supports an optional S3 bucket policy that denies requests made without HTTPS.

The policy uses the AWS condition key:

```text
aws:SecureTransport
```

When HTTPS enforcement is enabled, requests made over HTTP are denied.

The module uses a Boolean variable to control whether this policy is created.

**Local testing:** HTTPS enforcement is disabled in Floci because the local S3 endpoint uses HTTP.

**Real AWS deployment:** HTTPS enforcement should normally be enabled to protect data during transfer.

---

## 7. Terraform Setup and Execution

### Prerequisites

- Terraform installed.
- Docker Desktop running.
- Floci container running.
- AWS CLI installed.
- Git installed.
- VS Code or another code editor.

### Step 1 — Clone the Repository

```bash
git clone https://github.com/RupshaSaha/secure-s3-terraform-devsecops.git
```

```bash
cd secure-s3-terraform-devsecops
```

### Step 2 — Configure Local Variables

Create a `terraform.tfvars` file with the following values:

```hcl
s3_endpoint = "http://localhost:4566"

dev_bucket  = "secure-s3-project-dev-202611"
test_bucket = "secure-s3-project-test-202611"
prod_bucket = "secure-s3-project-prod-202611"

dev_versioning  = true
test_versioning = true
prod_versioning = true

dev_secure_transport  = false
test_secure_transport = false
prod_secure_transport = false
```

Bucket names may need to be changed to avoid conflicts.

### Step 3 — Initialize Terraform

```bash
terraform init
```

Downloads the required providers and initializes the modules.

### Step 4 — Format Terraform Code

```bash
terraform fmt -recursive
```

Formats Terraform files.

### Step 5 — Validate Configuration

```bash
terraform validate
```

Checks Terraform configuration syntax and structure.

### Step 6 — Preview Infrastructure Changes

```bash
terraform plan
```

Shows which resources Terraform intends to create, update, or destroy.

### Step 7 — Deploy Infrastructure

```bash
terraform apply
```

Applies the proposed infrastructure changes after confirmation.

### Step 8 — Check Terraform State

```bash
terraform state list
```

Displays the resources managed by Terraform.

---

## 8. Verify S3 Infrastructure Using AWS CLI

Floci provides a local S3-compatible API that can be accessed using AWS CLI.

### List S3 Buckets

```bash
aws --endpoint-url=http://localhost:4566 s3api list-buckets
```

### Check Bucket Versioning

```bash
aws --endpoint-url=http://localhost:4566 s3api get-bucket-versioning --bucket secure-s3-project-dev-202611
```

### Check Bucket Encryption

```bash
aws --endpoint-url=http://localhost:4566 s3api get-bucket-encryption --bucket secure-s3-project-dev-202611
```

### Check Public Access Block

```bash
aws --endpoint-url=http://localhost:4566 s3api get-public-access-block --bucket secure-s3-project-dev-202611
```

### Check Object Ownership

```bash
aws --endpoint-url=http://localhost:4566 s3api get-bucket-ownership-controls --bucket secure-s3-project-dev-202611
```

### Check Lifecycle Configuration

```bash
aws --endpoint-url=http://localhost:4566 s3api get-bucket-lifecycle-configuration --bucket secure-s3-project-dev-202611
```

The same commands can be used for Testing and Production by changing the bucket name.

---

## 9. Docker Setup

The project uses Docker to run Floci and Jenkins.

### Create a Shared Docker Network

```bash
docker network create terraform-lab-net
```

### Connect Floci to the Network

```bash
docker network connect terraform-lab-net floci
```

### Connect Jenkins to the Network

```bash
docker network connect terraform-lab-net Jenkins_custom
```

### Verify Docker Network

```bash
docker network inspect terraform-lab-net
```

### Verify Jenkins-to-Floci Connectivity

```bash
docker exec Jenkins_custom bash -c "curl -s -o /dev/null -w '%{http_code}' http://floci:4566"
```

An HTTP response of `200` confirms that Jenkins can reach the Floci endpoint.

---

## 10. Jenkins CI/CD Pipeline

The Jenkins pipeline automates the infrastructure deployment workflow.

### Pipeline Stages

| Stage | Purpose |
|---|---|
| Checkout | Download Terraform code from GitHub |
| Terraform Format | Check Terraform formatting |
| Terraform Init | Initialize Terraform and required providers |
| Terraform Validate | Check Terraform configuration |
| Checkov Scan | Scan infrastructure code for security issues |
| Terraform Plan | Preview infrastructure changes |
| Manual Approval | Require approval before deployment |
| Terraform Apply | Apply approved infrastructure changes |

### Jenkins Configuration

The pipeline runs inside the Jenkins Docker container.

Jenkins communicates with Floci through the shared Docker network using:

```text
http://floci:4566
```

A Jenkins-specific variable file is used to override the endpoint:

```hcl
s3_endpoint = "http://floci:4566"
```

Terraform commands executed by Jenkins use:

```bash
terraform plan -var-file="jenkins.tfvars"
```

```bash
terraform apply -var-file="jenkins.tfvars"
```

The local `terraform.tfvars` file supplies the remaining environment values.

### Manual Deployment Approval

A manual approval stage is placed between Terraform Plan and Terraform Apply.

This ensures infrastructure changes are reviewed before deployment.

The approval stage is especially important for Production environments.

---

## 11. Checkov Security Scanning

Checkov is used to scan Terraform code for infrastructure security issues.

The scan is integrated into the Jenkins pipeline.

Example command:

```bash
checkov -d .
```

The scan checks Terraform configuration against security rules, including controls related to:

- Public access.
- Encryption.
- Logging.
- Versioning.
- Access permissions.
- Other infrastructure security settings.

Scan findings are reviewed before deployment. Any accepted exceptions should be documented with a clear reason.

---

## 12. Git and GitHub Integration

Git is used to track changes in the Terraform configuration.

GitHub stores the project source code.

### Common Git Commands

```bash
git status
git add .
git commit -m "Update Terraform configuration"
git push origin main
```

### Git Security

The `.gitignore` file excludes local and sensitive files, including:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
*.tfvars.json
*.tfplan
```

The `.terraform.lock.hcl` file is committed to keep provider versions consistent.

Secrets and real cloud credentials must not be committed to Git.

---

## 13. Terraform State Management

Terraform uses a state file to track resources it manages.

This project uses a local Terraform state file:

```text
terraform.tfstate
```

The state records resources belonging to all three environments.

Example:

```text
module.dev_bucket.aws_s3_bucket.this
module.test_bucket.aws_s3_bucket.this
module.prod_bucket.aws_s3_bucket.this
```

### Important State Considerations

- The project has a separate Terraform state from earlier Terraform practice projects.
- Dev, Test, and Production are separate S3 buckets and module instances.
- They are **not stored in separate environment state files**.
- State files are excluded from Git.
- A real production setup should use a secure remote backend with state locking, controlled access, and suitable separation between environments.

---

## 14. Infrastructure Testing and Verification

The infrastructure is checked through several methods.

### Terraform Checks

- `terraform fmt`
- `terraform validate`
- `terraform plan`
- `terraform state list`

### AWS CLI Checks

- Verify bucket creation.
- Verify versioning.
- Verify encryption.
- Verify public access blocking.
- Verify object ownership.
- Verify lifecycle configuration.

### CI/CD Checks

- Verify Jenkins can access the GitHub repository.
- Verify Jenkins can communicate with Floci.
- Verify Terraform commands run inside Jenkins.
- Verify Checkov scan results.
- Verify manual approval prevents automatic deployment.
- Verify Terraform Apply runs only after approval.

### Security Testing Limitation

Floci is a local AWS emulator. A successful configuration check does not prove that every AWS security rule is enforced exactly as it would be in real AWS.

Security controls should be tested again when deploying to an actual AWS environment.

---

## 15. Project Results

The Terraform implementation provisions three S3 buckets with:

- AES256 server-side encryption.
- Versioning enabled.
- Public access block settings enabled.
- Bucket owner enforced.
- Lifecycle cleanup for incomplete multipart uploads.
- Optional HTTPS-only bucket policy.
- Environment-specific configuration.
- Reusable Terraform modules.

The CI/CD design adds automated Terraform checks, security scanning, deployment planning, and manual approval before applying infrastructure changes.

---

## 16. Key DevSecOps Concepts Demonstrated

This project demonstrates:

1. **Infrastructure as Code:** Infrastructure is defined using Terraform rather than created manually.
2. **Reusable Modules:** A single Terraform module manages multiple environments.
3. **Security by Design:** Security controls are included in the infrastructure configuration.
4. **Shift-Left Security:** Checkov scans infrastructure code before deployment.
5. **CI/CD Automation:** Jenkins automates validation and deployment steps.
6. **Change Review:** Terraform Plan shows changes before deployment.
7. **Manual Approval:** Infrastructure changes require approval before Apply.
8. **Version Control:** GitHub stores and tracks infrastructure code.
9. **Local Cloud Testing:** Floci provides a local environment for learning and testing AWS services.
10. **State Management:** Terraform tracks infrastructure resources through its state file.

---

## 17. Limitations and Production Considerations

This project is intended for local learning and DevSecOps practice.

Before using the configuration in a real AWS production environment, additional changes would be needed:

- Replace Floci endpoints and dummy credentials with secure AWS authentication.
- Enable HTTPS enforcement.
- Use a secure remote Terraform backend with state locking.
- Separate Production state and access permissions from non-production environments.
- Use IAM roles and least-privilege permissions.
- Configure suitable S3 access logging and monitoring.
- Review Checkov findings and security exceptions.
- Test infrastructure changes in a non-production environment first.
- Protect Jenkins credentials and restrict deployment permissions.

---

## 18. Conclusion

This project demonstrates a DevSecOps approach to managing S3 infrastructure with Terraform.

By combining reusable Terraform modules, S3 security controls, local AWS testing, GitHub version control, Jenkins automation, Checkov scanning, and manual deployment approval, the project provides practical experience with infrastructure automation and security checks.

The main goal is to understand how infrastructure can be created, tested, reviewed, and managed through a controlled CI/CD workflow.