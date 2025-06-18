resource "azurerm_resource_group" "rg-app-law" {
  name = "rg-app-law"
  location = "uksouth"
}

resource "azurerm_log_analytics_workspace" "app-workspace" {
  name = "law-app-${random_string.web-app-name.result}"
  location = "uksouth"
  resource_group_name = azurerm_resource_group.rg-app-law.name
}

data "azurerm_monitor_diagnostic_categories" "web-app" {
  resource_id = azurerm_windows_web_app.lab-app.id
}

data "azurerm_monitor_diagnostic_categories" "sql-database" {
  resource_id = azurerm_mssql_database.sql-db-01.id
}

resource "azurerm_monitor_diagnostic_setting" "app" {
  name = "app"
  target_resource_id = azurerm_windows_web_app.lab-app.id

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.web-app.log_category_types
    content {
      category = enabled_log.value
    }
  }

  enabled_metric {
    category = "AllMetrics"
  }

}

resource "azurerm_monitor_diagnostic_setting" "sql-db" {
  name = "sql"
  target_resource_id = azurerm_mssql_database.sql-db-01.id

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.sql-database.log_category_types
    content {
      category = enabled_log.value
    }
  }

  enabled_metric {
    category = "AllMetrics"
  }

}