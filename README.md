# Terraform AWS Multi-Environment

Provision **dev**, **stg** and **prod** environments on AWS from a **single Terraform codebase** using **workspaces** and **reusable modules**. Switch workspace, run `terraform apply`, and the infrastructure scales to match that environment.

## What it does

The same code creates EC2 instances, S3 buckets and DynamoDB tables. The number of each resource is decided by the active Terraform workspace.

| Workspace | EC2 instances | S3 buckets | DynamoDB tables |
|-----------|:-------------:|:----------:|:---------------:|
| `dev`     | 1 | 1 | 1 |
| `stg`     | 2 | 2 | 2 |
| `prod`    | 4 | 3 | 2 |

Any other workspace (including `default`) falls back to the `dev` sizing.

## How it works

```
terraform.workspace ──► locals.env map ──► local.current
                                              │
                 ┌────────────────────────────┼────────────────────────────┐
                 ▼                            ▼                            ▼
          module "ec2"                 module "s3"                 module "dynamodb"
     (instance_count, AMI,        (bucket_count, env)          (table_count, env)
      type, SSH key, env)
```

- `main.tf` holds a `locals` map with per-environment counts and picks the right one with `lookup(local.env, terraform.workspace, local.env["dev"])`.
- Each resource type lives in its own module under `modules/`, receiving the environment name and count as inputs.
- `data.tf` looks up the latest **Ubuntu 24.04 LTS** AMI (owner `099720109477`, Canonical) so the AMI ID is never hard-coded.

## Project structure

```
.
├── main.tf              # Per-environment config map + module calls
├── variables.tf         # instance_type, key_public_path
├── data.tf              # Latest Ubuntu 24.04 AMI lookup
├── providers.tf         # AWS provider (us-west-2)
├── terraform.tf         # Required provider + version pin (hashicorp/aws 6.65.0)
├── output.tf            # Workspace, instance IDs/IPs, bucket and table names
├── terraform-key.pub    # Public SSH key attached to the EC2 instances
├── .terraform.lock.hcl  # Provider lock file
└── modules/
    ├── ec2/
    ├── s3/
    └── dynamodb/
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- An AWS account and credentials configured (`aws configure` or environment variables)
- An SSH key pair. Generate one if you don't have it, then place the public key at the path in `key_public_path`:

```bash
ssh-keygen -t ed25519 -f terraform-key
# keep terraform-key (private) safe and out of Git; terraform-key.pub is used by Terraform
```

## Usage

```bash
# 1. Clone
git clone https://github.com/shashankcodes-10/terraform-aws-multi-env.git
cd terraform-aws-multi-env

# 2. Initialise providers and modules
terraform init

# 3. Create and select a workspace
terraform workspace new dev        # first time only
terraform workspace select dev

# 4. Preview and apply
terraform plan
terraform apply

# 5. Repeat for other environments
terraform workspace new stg
terraform apply

terraform workspace new prod
terraform apply
```

Useful workspace commands:

```bash
terraform workspace list     # show all workspaces (* marks the active one)
terraform workspace show     # print the current workspace
```

## Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `instance_type` | `string` | `t3.micro` | EC2 instance type |
| `key_public_path` | `string` | `terraform-key.pub` | Path to the public SSH key used for the instances |

Override at apply time if needed:

```bash
terraform apply -var="instance_type=t3.small"
```

## Outputs

| Output | Description |
|--------|-------------|
| `current_workspace` | The workspace Terraform is operating in |
| `ec2_instance_ids` | IDs of the created EC2 instances |
| `ec2_public_ips` | Public IPs of the EC2 instances |
| `s3_bucket_names` | Names of the created S3 buckets |
| `dynamodb_table_names` | Names of the created DynamoDB tables |

## Cleanup

Destroy each environment separately to avoid surprise AWS charges:

```bash
terraform workspace select prod && terraform destroy
terraform workspace select stg  && terraform destroy
terraform workspace select dev  && terraform destroy
```

## Notes and possible improvements

- State is stored locally per workspace. For team use, move to a remote backend (S3 bucket + DynamoDB state locking).
- Never commit the private key. Keep `terraform-key` and `*.tfstate` in `.gitignore`.
- Planned next steps: remote state, a CI/CD pipeline (`terraform fmt`, `validate`, `plan` on pull requests), and a VPC module.

## Tech stack

Terraform · AWS (EC2, S3, DynamoDB) · Terraform Workspaces · Terraform Modules · Infrastructure as Code

## Author

**Shashank Pipal**
[GitHub](https://github.com/shashankcodes-10) · [LinkedIn](https://linkedin.com/in/shashank-pipal/)
