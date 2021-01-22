# Add Custom domain to an Azure Spring Cloud application with SSL/TLS


## Overview
When you deploy an application to an Azure Spring cloud environment, it will publish the application using the domain suffix azuremicroservices.io or private.azuremicroservice.io when injected into a VNet. A custom domain allows you to utilize your own custom domain suffix for your Azure Spring Cloud application endpoint.

## Prerequisites

1. [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

2. One of the following Quickstarts deployed: [ARM](https://github.com/Azure/azure-spring-cloud-reference-architecture/tree/main/ARM) or [Terraform](https://github.com/Azure/azure-spring-cloud-reference-architecture/tree/main/terraform)

3. An SSL/TLS certificate file with private key in PFX or PEM format for the custom domain

## Configuration

1. Create a bash script with environmental variables by making a copy of the [setup-env-variables-custom-domain.sh](https://github.com/Azure/azure-spring-cloud-reference-architecture/tree/main/custom-domain/setup-env-variables-custom-domain.sh) file. Modify the values of the variables.
   Then, set the environment

```bash
    source setup-env-variables-custom-domain.sh
```

2. Currently, if the Azure Key Vault being used has a firewall configured, the Azure Spring cloud management IP addresses need to be added to the firewall. Use the following command:

```bash
    export MGMT_IPS=(20.53.123.160 52.143.241.210 40.65.234.114 52.142.20.14 20.54.40.121 40.80.210.49 52.253.84.152 20.49.137.168 40.74.8.134 51.143.48.243)  

    for IP in "${MGMT_IPS[@]}"; do az keyvault network-rule add --resource-group ${RESOURCE_GROUP} --name ${VAULT_NAME} --ip-address "$IP"; done`
```

3. Set your default Azure Spring Cloud resource group name and cluster name:

```bash
    az configure --defaults \
        group=${RESOURCE_GROUP} \
        location=${REGION} \
        spring-cloud=${SPRING_CLOUD_SERVICE}
```

4. Use either the [configure-custom-domain.sh](https://github.com/Azure/azure-spring-cloud-reference-architecture/tree/main/custom-domain/configure-custom-domain.sh) script provided in this repo **OR** run the individual commands within the script file. Make sure to run on the Virtual Machine running inside the Virtual Network

Create a new Azure Private DNS Zone for the custom domain

```bash
    
```

5. FINISH THIS - Add a dns record for the custom host name pointing to the Vnet Injection Endpoint of the Azure Spring Cloud Service

6. Log into the virtual machine running in the virtual network and test the custom domain.

## Additional Notes

Azure Spring Cloud custom domain setup - https://docs.microsoft.com/en-us/azure/spring-cloud/spring-cloud-tutorial-custom-domain

Azure Private DNS Zones - https://docs.microsoft.com/en-us/azure/dns/private-dns-overview