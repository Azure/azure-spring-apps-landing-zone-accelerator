#!/usr/bin/env bash

# === ARM ===
export RESOURCE_GROUP=resource-group-name # customize this - RG that contains Key Vault and Azure Spring Cloud resources

# === Key Vault ===
export VAULT_NAME=key-vault-resource-name # customize this - Existing Key Vault resource name
export VAULT_URI=https://${VAULT_NAME}.vault.azure.net/ 
export CERT_FILE=app_domain_com.pfx # customize this - File name or path to PFX/PEM file with private key
export CERT_PASSWORD=password # customize this - Password for certificate file

# === Azure Spring Cloud ===
export KV_CERT_NAME=app-domain-com # customize this - Name of certificate added to Key Vault
export SPRING_CERT_NAME=test-hudsoncorp-net # customize this - Name of certificate to Azure Spring Cloud
export DOMAIN_NAME=app.domain.com # customize this - Name of custom domain name
export APP_NAME=spring-app-name # customize this - name of Azure Spring cloud app to add custom domain with SSL/TLS
export REGION=eastus # customize this - if needed
export SPRING_CLOUD_SERVICE=azure-spring-cloud-name # customize this - Name of Azure Spring Cloud Service