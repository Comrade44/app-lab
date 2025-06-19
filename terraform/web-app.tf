resource "azurerm_resource_group" "rg-web-app" {
  name     = "rg-web-app"
  location = "uksouth"
}

resource "random_string" "web-app-name" {
  length  = 4
  special = false
}

resource "azurerm_service_plan" "lab-service-plan" {
  name                = "lab-service-plan"
  location            = azurerm_resource_group.rg-web-app.location
  resource_group_name = azurerm_resource_group.rg-web-app.name
  os_type             = "Windows"
  sku_name            = "D1"
}

resource "azurerm_windows_web_app" "lab-app" {
  name                = "lab-app-${random_string.web-app-name.result}"
  location            = azurerm_resource_group.rg-web-app.location
  resource_group_name = azurerm_resource_group.rg-web-app.name
  service_plan_id     = azurerm_service_plan.lab-service-plan.id
  site_config {
    always_on = false

  }
  app_settings = {
    "AZURE_SQL_CONNECTIONSTRING" = <<EOF
      Server=tcp:${azurerm_mssql_server.sql-server.fully_qualified_domain_name},1433;
      Initial Catalog=${azurerm_mssql_database.sql-db-01.name};
      Persist Security Info=False;
      User ID=${azurerm_mssql_server.sql-server.administrator_login};
      Password=${azurerm_mssql_server.sql-server.administrator_login_password};
      MultipleActiveResultSets=False;
      Encrypt=True;
      TrustServerCertificate=False;
      Connection Timeout=30;
      EOF
#    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.web-app-insights.connection_string
#    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
  }
}