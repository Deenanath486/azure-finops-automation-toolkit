resource "azurerm_resource_group" "rg" {
  name     = "rg-finops-automation-prod"
  location = "centralindia"

  tags = {
    Environment = "Production"
    Function    = "FinOps-Automation"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_automation_account" "auto" {
  name                = "aa-finops-enterprise"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned"
  }

  tags = azurerm_resource_group.rg.tags
}

# Daily Evening Shutdown Schedule (8:00 PM IST)
resource "azurerm_automation_schedule" "shutdown_schedule" {
  name                    = "daily-evening-shutdown"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.auto.name
  frequency               = "Day"
  interval                = 1
  start_time              = "2026-01-01T20:00:00+05:30"
  description             = "Automatically shuts down non-prod VMs at 8:00 PM IST"
}

# Daily Morning Startup Schedule (8:00 AM IST)
resource "azurerm_automation_schedule" "startup_schedule" {
  name                    = "daily-morning-startup"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.auto.name
  frequency               = "Day"
  interval                = 1
  start_time              = "2026-01-01T08:00:00+05:30"
  description             = "Automatically starts non-prod VMs at 8:00 AM IST on weekdays"
}
