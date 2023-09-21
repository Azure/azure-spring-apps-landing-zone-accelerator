output "openai_key" {
  value = azurerm_cognitive_account.open_ai_account.primary_access_key
}

output "openai_endpoint" {
  value = azurerm_cognitive_account.open_ai_account.endpoint
}
