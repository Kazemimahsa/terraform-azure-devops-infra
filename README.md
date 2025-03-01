# Terraform Azure DevOps Infrastructure

This project automates the deployment of Azure infrastructure using Terraform and Azure DevOps.

## 🚀 Features:
- Uses Terraform to provision:
  - Azure Resource Group
  - Storage Account
  - Key Vault (with predefined secrets)
  - App Service & App Service Plan
  - Virtual Network & Subnet
  - Network Security Group (NSG)
- Azure DevOps pipeline for automatic deployment

## 📂 Project Structure:
- `main.tf` → Defines Azure resources
- `variables.tf` → Manages input variables
- `azure-pipelines.yml` → Azure DevOps pipeline configuration

## 🛠️ How to Deploy:
1. Clone this repo:  
   ```sh
   git clone https://github.com/your-username/terraform-azure-devops-infra.git

