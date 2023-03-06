# Create Azure Application Gateway with WAF

The following will be created:
* Resource Group for Azure Application gateway (main.tf)
* Azure Application Gateway (App_Gateway.tf)

**Note**: You will need a TLS/SSL Certificate with the Private Key (PFX Format) for the Application Gateway Listener. The PFX certificate on the listener needs the entire certificate chain and the password must be 4 to 12 characters. For the purpose of this quickstart, you can use a [Self Signed Certificate](https://learn.microsoft.com/EN-us/azure/application-gateway/create-ssl-portal#create-a-self-signed-certificate) or one issued from an internal Certificate Authority. Copy the PFX file to the /Scenarios/ASA-Secure-Baseline-/Terraform/07-LZ-AppGateway folder.



Review and if needed, comment out and modify the variables within the "07 Application Gateway" section of the common variable definitons file [parameters.tfvars](./parameters.tfvars). 

Sample:

```bash
##################################################
# 07 Application Gateway
##################################################

    # azure_app_gateway_zones        = [1,2,3]
    # backendPoolFQDN                = "default-replace-me.private.azuremicroservices.io"
    # certfilename                   = "mycertificate.pfx"
    
```

## Deploy Azure Application Gateway

Navigate to the "/Scenarios/ASA-Secure-Baseline/Terraform/07-LZ-AppGateway" directory. 

```bash
cd ../07-LZ-AppGateway
```

Deploy using Terraform Init, Plan and Apply

```bash

# Ensure the following state management runtime variables have been defined:
#   STORAGEACCOUNTNAME = 'xxxxx'
#   CONTAINERNAME      = 'xxxxx'
#   TFSTATE_RG         = 'xxxxx'


terraform init -backend-config="resource_group_name=$TFSTATE_RG" -backend-config="storage_account_name=$STORAGEACCOUNTNAME" -backend-config="container_name=$CONTAINERNAME"
```

```bash
terraform plan -out my.plan --var-file ../parameters.tfvars
```

```bash
terraform apply my.plan
```

### Next step

:arrow_forward: [Cleanup](./08-cleanup.md)