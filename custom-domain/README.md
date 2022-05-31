# Add Custom domain to an Azure Spring Apps application with SSL/TLS

## Overview
When you deploy an application to an Azure Spring cloud environment, it will publish the application using the domain suffix azuremicroservices.io or private.azuremicroservice.io when injected into a VNet. A custom domain allows you to utilize your own custom domain for your Azure Spring Apps application endpoint.

## Prerequisites

1. [Install Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli).

2. One of the following Quickstarts deployed: [ARM](https://github.com/Azure/azure-spring-cloud-reference-architecture/tree/main/ARM) or [Terraform](https://github.com/Azure/azure-spring-cloud-reference-architecture/tree/main/terraform).

3. An SSL/TLS certificate file with private key in PFX or PEM format for the custom domain.

## Configuration

1. Create a bash script with environmental variables by making a copy of the [setup-env-variables-custom-domain.sh](https://github.com/Azure/azure-spring-cloud-reference-architecture/tree/main/custom-domain/setup-env-variables-custom-domain.sh) file. Modify the values of the variables.
   Then, set the environment.

```bash
    source setup-env-variables-custom-domain.sh
```

2. Currently, if the Azure Key Vault being used has a firewall configured, the Azure Spring cloud management IP addresses need to be added to the firewall. Use the following command:

```bash
    export MGMT_IPS=(20.53.123.160 52.143.241.210 40.65.234.114 52.142.20.14 20.54.40.121 40.80.210.49 52.253.84.152 20.49.137.168 40.74.8.134 51.143.48.243)  

    for IP in "${MGMT_IPS[@]}"; do az keyvault network-rule add --resource-group ${RESOURCE_GROUP} --name ${VAULT_NAME} --ip-address "$IP"; done
```

3. Set your default Azure Spring Apps resource group name and cluster name.

```bash
    az configure --defaults \
        group=${RESOURCE_GROUP} \
        location=${REGION} \
        spring-cloud=${SPRING_CLOUD_SERVICE}
```

4. Use either the [configure-custom-domain.sh](https://github.com/Azure/azure-spring-cloud-reference-architecture/tree/main/custom-domain/configure-custom-domain.sh) script provided in this repo **OR** run the individual commands within the script file. Make sure to run on the Virtual Machine running inside the Virtual Network

5. Create a new Azure Private DNS Zone for the custom domain. 

```bash
   az network private-dns zone create -g ${RESOURCE_GROUP} \
   -n ${DOMAIN_SUFFIX}
```

6. Link the Private DNS Zone to the Hub virtual network:

```bash
    az network private-dns link vnet create --resource-group ${RESOURCE_GROUP} \
    --name custom-domain-hub-link \
    --zone-name ${DOMAIN_SUFFIX} \
    --virtual-network vnet-hub \
    -e false
```

7. Add a new A record for the application within the new DNS Zone. Replace yourIPAddress with your Azure Spring Apps endpoint private IP. You can get the IP address of your spring cloud VNet injection endpoint from the Azure Portal.

![lab image](https://github.com/Azure/azure-spring-cloud-reference-architecture/blob/main/custom-domain/images/vnetinjection.jpeg)

```bash
    az network private-dns record-set a add-record --resource-group ${RESOURCE_GROUP} \
    --record-set-name ${DOMAIN_HOSTNAME} \
    --zone-name ${DOMAIN_SUFFIX} \
    --ipv4-address '<yourIPAddress>'
```

8. connect to the jump VM running in the virtual network and test the custom domain from a browser.

9. Clear the Azure CLI defaults using the following.

```bash
    az configure --defaults location='' \
    group='' \
    spring-cloud=''
```

## Additional Notes

Azure Spring Apps custom domain setup - https://docs.microsoft.com/azure/spring-cloud/spring-cloud-tutorial-custom-domain

Azure Private DNS Zones - https://docs.microsoft.com/azure/dns/private-dns-overview
