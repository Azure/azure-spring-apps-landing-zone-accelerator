output "mysql_database_name" {
  value = azurerm_mysql_flexible_database.petclinic_database.name
}

output "mysql_server_name" {
  value = azurerm_mysql_flexible_server.mysql.fqdn
}




