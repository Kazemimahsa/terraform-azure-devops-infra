terraform {
  required_version = ">= 1.5.0"

  backend "azurerm" {
    resource_group_name   = "rg-assignment-02"
    storage_account_name  = "stassignterraformstate01"
    container_name        = "terraform-state"
    key                   = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "assignment" {
  name     = "rg-assignment-02"
  location = "West Europe"
}

# Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = "stmahsaassignment01"
  resource_group_name      = azurerm_resource_group.assignment.name
  location                 = azurerm_resource_group.assignment.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Key Vault
resource "azurerm_key_vault" "keyvault" {
  name                        = "kv-assignment-01"
  resource_group_name         = azurerm_resource_group.assignment.name
  location                    = azurerm_resource_group.assignment.location
  tenant_id                   = "your-tenant-id"
  sku_name                    = "standard"
}

# Key Vault Secrets
resource "azurerm_key_vault_secret" "username" {
  name         = "username"
  value        = "myassignment"
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "azurerm_key_vault_secret" "password" {
  name         = "pass"
  value        = "n!bdi73IHQ&K"
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "azurerm_key_vault_secret" "jdbc_connection" {
  name         = "jdbcdbconnectionstring"
  value        = "jdbc:sqlserver://xyz-sold-dev-sql.database.windows.net:1433;database=mydatabase-dev-sqldb;user=Cloud@xyz-sold-dev-sql;password=ljasdf7w3jbshdw2#gsdk;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"
  key_vault_id = azurerm_key_vault.keyvault.id
}

# App Service Plan
resource "azurerm_app_service_plan" "app_plan" {
  name                = "appsvc-assignment-01"
  resource_group_name = azurerm_resource_group.assignment.name
  location            = azurerm_resource_group.assignment.location
  kind                = "Windows"
  sku {
    tier = "Basic"
    size = "B1"
  }
}

# App Service
resource "azurerm_app_service" "app" {
  name                = "app-assignment-01"
  location            = azurerm_resource_group.assignment.location
  resource_group_name = azurerm_resource_group.assignment.name
  app_service_plan_id = azurerm_app_service_plan.app_plan.id
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-assignment-01"
  location            = azurerm_resource_group.assignment.location
  resource_group_name = azurerm_resource_group.assignment.name
  address_space       = ["172.16.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "snet-workloadxyz-01"
  resource_group_name  = azurerm_resource_group.assignment.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["172.16.10.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-workloadxyz-01"
  location            = azurerm_resource_group.assignment.location
  resource_group_name = azurerm_resource_group.assignment.name
}

# NSG Rule - Allow inbound 443
resource "azurerm_network_security_rule" "allow_https" {
  name                        = "allow-https"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.assignment.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}
