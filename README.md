# aws_IaC
Set up AWS instances using Infrastructure as Code through Terraform.
# Terraform AWS EC2 Multi-OS Deployment

This repository contains a Terraform configuration (`main.tf`) to automate the deployment of three different virtual machines (EC2 instances) in your AWS account: a Windows Server, an Ubuntu Server, and an Amazon Linux 2023 (AL23) Server. It also sets up a common Security Group for access.

## Table of Contents

-   [Project Overview](#project-overview)
-   [Prerequisites](#prerequisites)
-   [Setup Instructions](#setup-instructions)
-   [Usage](#usage)
-   [Accessing the Servers](#accessing-the-servers)
-   [Cleanup](#cleanup)
-   [Important Notes](#important-notes)

## Project Overview

This Terraform configuration will deploy:

* **One Windows Server instance:** Running Microsoft Windows Server 2025 Base (fulfilling the Windows 10 deliverable).
* **One Ubuntu Server instance:** Running Ubuntu 22.04 LTS (or similar, based on your AMI).
* **One Amazon Linux 2023 (AL23) instance:** Running the latest Amazon Linux.
* **One Security Group:** A common firewall rule set allowing inbound RDP (port 3389) and SSH (port 22) access from anywhere (`0.0.0.0/0`).
* **References an existing Key Pair:** Used for password decryption for Windows and SSH access for Linux instances.

All resources are deployed in the `us-east-1` AWS region.

## Prerequisites

Before you begin, ensure you have the following:

1.  **AWS Account Access:** Access to an AWS account (e.g., your ACG Sandbox).
2.  **AWS CLI Installed & Confgured:**
    * [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
    * Configure your AWS CLI with your programmatic Access Key ID, Secret Access Key, and default region (`us-east-1`) by running `aws configure`. Ensure your temporary sandbox credentials are up-to-date.
3.  **Terraform Installed:**
    * [Install Terraform](https://developer.hashicorp.com/terraform/install)
    * Verify installation: `terraform -v`
4.  **EC2 Key Pair Created:**
    * In your AWS EC2 Console (`us-east-1` region), navigate to **Key Pairs**.
    * Create a new key pair named `al23-key-terraform` (or whatever you set `key_name` to in `main.tf`).
    * Download the `.pem` file and store it securely (e.g., in your `Downloads` folder). This key is crucial for connecting to your instances.
5.  **AMI IDs Confirmed:** The `main.tf` file contains specific AMI IDs. While current at the time of creation, AMI IDs can change. Verify the latest AMI IDs for `us-east-1` directly in your AWS EC2 Console under "AMIs" -> "Public images" for:
    * **Windows Server 2025 Base:** (`ami-02b60b5095d1e5227`)
    * **Ubuntu Server 22.04 LTS:** (`ami-020cba7c55df1f615`)
    * **Amazon Linux 2023:** (`ami-09e6f87a47903347c`)
    * **Update `main.tf` with the latest AMI IDs if different.**

## Setup Instructions

1.  **Clone this repository:**
    ```bash
    git clone <repository_url>
    cd <repository_name> # e.g., cd aws_ec2
    ```
2.  **Open `main.tf`:** Open the `main.tf` file in a text editor (e.g., VS Code).
3.  **Verify/Update Placeholders:** Ensure the `key_name` in the `data "aws_key_pair" "server_key"` block and the `ami` IDs in each `aws_instance` resource block match your actual key pair name and the latest AMI IDs from your AWS console.
4.  **Save the `main.tf` file.**

## Usage

Navigate to the project directory in your terminal (e.g., `cd C:\Users\YourUser\aws_ec2`).

1.  **Initialize Terraform:** This downloads the necessary AWS provider plugins.
    ```bash
    terraform init
    ```
2.  **Review the Execution Plan:** This shows you exactly what Terraform will create, modify, or destroy in your AWS account without making any changes yet.
    ```bash
    terraform plan
    ```
    * Review the output carefully. You should see `3 to add` (for the 3 instances) and `1 to add` (for the security group), along with `- destroy` if previous instances/security groups were terminated by your sandbox.
3.  **Apply the Configuration:** This will provision the resources in your AWS account.
    ```bash
    terraform apply
    ```
    * Type `yes` when prompted to confirm the actions. This step will take several minutes.

## Accessing the Servers

After `terraform apply` completes, the public IP addresses of your servers will be displayed in the output. Keep these handy.

**Common Usernames:**
* **Windows Server:** `Administrator`
* **Ubuntu Server:** `ubuntu`
* **Amazon Linux 2023:** `ec2-user`

**1. Connecting to Windows Server (RDP)**

* Go to your AWS EC2 Console (`us-east-1` region) -> **Instances**.
* Select your `WinServer01-Terraform` instance.
* Click **"Connect"** -> **"RDP client"** tab.
* Click **"Get password"**. Browse to and upload your `al23-key-terraform.pem` (or your actual key pair .pem file). Click "Decrypt Password" and copy the Administrator password.
* Click **"Download remote desktop file"**. Open the downloaded `.rdp` file and use the username `Administrator` and the decrypted password to connect.

**2. Connecting to Ubuntu Server (SSH)**

* Open your terminal (e.g., PowerShell, Git Bash).
* Navigate to the directory where your `.pem` file is saved (e.g., `cd C:\Users\YourUser\Downloads`).
* Run the SSH command (replace `3.80.81.48` with your actual Ubuntu Public IP):
    ```bash
    ssh -i .\al23-key-terraform.pem ubuntu@3.80.81.48
    ```
    *(Use `.\` for PowerShell; `chmod 400 your-key-name.pem` if using Git Bash/Linux/macOS).*

**3. Connecting to Amazon Linux 2023 (AL23) Server (SSH)**

* Open your terminal (e.g., PowerShell, Git Bash).
* Navigate to the directory where your `.pem` file is saved (e.g., `cd C:\Users\YourUser\Downloads`).
* Run the SSH command (replace `3.87.206.114` with your actual AL23 Public IP):
    ```bash
    ssh -i .\al23-key-terraform.pem ec2-user@3.87.206.114
    ```
    *(Use `.\` for PowerShell; `chmod 400 your-key-name.pem` if using Git Bash/Linux/macOS).*

## Cleanup

To avoid unnecessary charges, always destroy your resources when you are finished.

1.  Navigate to your project directory in the terminal:
    ```bash
    cd C:\Users\YourUser\aws_ec2
    ```
2.  Run the destroy command:
    ```bash
    terraform destroy
    ```
3.  Type `yes` when prompted to confirm the deletion of all resources.

## Important Notes

* **AWS ACG Sandbox:** Resources in sandbox environments often have a limited lifespan and may be automatically terminated, causing your Terraform state to be out of sync. This is normal and handled by `terraform plan` refreshing the state.
* **Elastic IP Charges:** The Security Group created does **not** consume an Elastic IP address. However, if you manually associate an Elastic IP with a *stopped* instance, AWS charges for it. Always release unused Elastic IPs to avoid charges.
* **Security Group `0.0.0.0/0`:** The security group allows RDP and SSH from `0.0.0.0/0` (any IP address). For production environments, **always restrict this to known IP addresses/ranges** for enhanced security.
* **Key Pair Security:** Keep your `.pem` file secure. If it's compromised, anyone with it can access your instances.

---
