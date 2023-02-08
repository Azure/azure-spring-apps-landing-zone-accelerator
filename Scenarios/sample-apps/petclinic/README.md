
## Pet clinic sample app deployment

This repository contains terraform to deploy the necessary components to run the Pet Clinic sample app in Azure Spring Apps.

This is targeted at deploying within the footprint of the ASA-Secure-Baseline, referencing the resource groups and networking from that deployment.



## Configure deployment parameters
Modify parameters.tfvars as needed

Sample:
```bash

##################################################
# REQUIRED
##################################################


# Subscription Id for the target Azure subscription
subscription_id = ""

# Name of Key Vault, this is randomized during deployment
key_vault_name = "kv-springlza-xxxx"

# Name of Spring Cloud Service, this is randomized during deployment
spring_cloud_service = "spring-springlza-dev-xxxx"
```

# Run Terraform Deployment


```bash

    # Login to Azure CLI
    az login

    # Change directory in the component and init terraform
    cd <xx-FolderName>
    terraform init

    # Update for backend coming soon
    #terraform init -backend-config="resource_group_name=$TFSTATE_RG" -backend-config="storage_account_name=$STORAGEACCOUNTNAME" #-backend-config="container_name=$CONTAINERNAME"

    # Plan and apply
    terraform plan -out my.plan --var-file parameters.tfvars
    terraform apply my.plan
```

# Deploy Petclinic via GitHub Actions

https://github.com/felipmiguel/spring-petclinic-microservices/tree/3.0.0

