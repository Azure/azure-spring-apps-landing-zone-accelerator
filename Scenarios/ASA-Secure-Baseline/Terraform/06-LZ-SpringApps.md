# Create Azure Spring Apps

The following will be created:
* Resource Group for Azure Spring Apps (main.tf)
* Azure Spring Apps (Standard or Enterprise)
* Application Insights (app_insights.tf)


Review and if needed, comment out and modify the variables within the "06 Azure Spring Apps" section of the common variable definitons file [parameters.tfvars](./parameters.tfvars). 

Sample:

```bash
##################################################
# 06 Azure Spring Apps
##################################################

    # spring_apps_zone_redundant     = true


```

## Deploy Azure Spring Apps Standard

Navigate to the "/Scenarios/ASA-Secure-Baseline-/Terraform/06-LZ-SpringApps-Standard" directory. 

```bash
cd ../06-LZ-SpringApps-Standard
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

## Deploy Azure Spring Apps Enterprise

Navigate to the "/Scenarios/ASA-Secure-Baseline/Terraform/06-LZ-SpringApps-Enterprise" directory. 

```bash
cd ../06-LZ-SpringApps-Enterprise
```

Deploy using Terraform Init, Plan and Apply

```bash
terraform init -backend-config="resource_group_name=$TFSTATE_RG" -backend-config="storage_account_name=$STORAGEACCOUNTNAME" -backend-config="container_name=$CONTAINERNAME"
```

```bash
terraform plan -out my.plan --var-file ../parameters.tfvars
```

```bash
terraform apply my.plan
```

### Next step

:arrow_forward: [Creation of Azure Application Gateway](./07-LZ-AppGateway.md)