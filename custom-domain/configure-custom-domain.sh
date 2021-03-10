#!/usr/bin/env bash

# Grant Azure Spring Cloud access to your Azure Key Vault
az keyvault set-policy -g ${RESOURCE_GROUP} -n ${VAULT_NAME} --object-id ${ASCDM_ID} --certificate-permissions get list --secret-permissions get list

# Import certificate file to Key Vault
az keyvault certificate import --file ${CERT_FILE} --name ${KV_CERT_NAME} --vault-name ${VAULT_NAME} --password ${CERT_PASSWORD}

# Import certificate into Azure Spring Cloud from Key Vault
az spring-cloud certificate add --name ${SPRING_CERT_NAME} --vault-uri ${VAULT_URI} --vault-certificate-name ${KV_CERT_NAME}

# Bind custom domain name to Spring Cloud app
az spring-cloud app custom-domain bind --domain-name ${DOMAIN_NAME} --app ${APP_NAME}

# Bind Certificate to spring cloud app
az spring-cloud app custom-domain update --domain-name ${DOMAIN_NAME} --certificate ${SPRING_CERT_NAME} --app ${APP_NAME}