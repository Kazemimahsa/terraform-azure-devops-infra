# main.tf

terraform {
  backend "azurerm" {}
  
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.20.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "rgassignment02" {
  name = "rg-assignment-02"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kvassignment01" {
  name = "kv-assignment-01"
  location = data.azurerm_resource_group.rgassignment02.location
  resource_group_name = data.azurerm_resource_group.rgassignment02.name
  sku_name = "standard"
  tenant_id = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization = true
}

resource "azurerm_role_assignment" "roleassignment01" {
  scope                = azurerm_key_vault.kvassignment01.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

// resource "azurerm_key_vault_secret" "username" {
//   name         = "username"
//   value        = "myassignment"
//   key_vault_id = azurerm_key_vault.kvassignment01.id
// }

// resource "azurerm_key_vault_secret" "pass" {
//   name         = "pass"
//   value        = "n!bdi73IHQ&K"
//   key_vault_id = azurerm_key_vault.kvassignment01.id
// }

// resource "azurerm_key_vault_secret" "jdbcdbconnectionstring" {
//   name         = "jdbcdbconnectionstring"
//   value        = "jdbc:sqlserver://xyz-sold-devsql.database.windows.net:1433;database=mydatabase-devsqldb;user=Cloud@xyz-sold-devsql;password=ljasdf7w3jbshdw2#gsdk;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"
//   key_vault_id = azurerm_key_vault.kvassignment01.id
// }

resource "azurerm_storage_account" "stmahsaassignment02" {
  name                     = "stmahsaassignment02"
  resource_group_name      = data.azurerm_resource_group.rgassignment02.name
  location                 = data.azurerm_resource_group.rgassignment02.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "appsvcassignment01" {
  name                = "appsvc-assignment-01"
  resource_group_name      = data.azurerm_resource_group.rgassignment02.name
  location                 = data.azurerm_resource_group.rgassignment02.location
  sku_name            = "B1"
  os_type             = "Windows"
}

resource "azurerm_windows_web_app" "appassignment01" {
  name                = "app-assignment-01"
  resource_group_name      = data.azurerm_resource_group.rgassignment02.name
  location                 = data.azurerm_resource_group.rgassignment02.location
  service_plan_id     = azurerm_service_plan.appsvcassignment01.id

  site_config {
    always_on = true
    application_stack {
      current_stack = "dotnet"
      dotnet_version = "v9.0"
    }
  }
}

resource "azurerm_network_security_group" "nsgworkloadxyz01" {
  name                = "nsg-workloadxyz-01"
  resource_group_name      = data.azurerm_resource_group.rgassignment02.name
  location                 = data.azurerm_resource_group.rgassignment02.location
}

resource "azurerm_virtual_network" "vnetassignment01" {
  name                = "vnet-assignment-01"
  resource_group_name      = data.azurerm_resource_group.rgassignment02.name
  location                 = data.azurerm_resource_group.rgassignment02.location
  address_space       = ["172.16.0.0/16"]

  subnet {
    name             = "snet-workloadxyz-01"
    address_prefixes = ["172.16.10.0/24"]
    security_group = azurerm_network_security_group.nsgworkloadxyz01.id
  }
}
