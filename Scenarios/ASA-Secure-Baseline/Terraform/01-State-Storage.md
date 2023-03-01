# Use the Azure CLI to create a storage account to store the Terraform state files.
This storage account will be used to store the state of each deployment step and will be accessed by Terraform to reference values stored in the various deployment state files.

Create some variables to start with

```bash
# Bash
REGION=<REGION>
STORAGEACCOUNTNAME=<UNIQUENAME>
CONTAINERNAME=springappsterraform
TFSTATE_RG=springappsterraform

      ## or ##

## PowerShell
$REGION="<REGION>"
$STORAGEACCOUNTNAME="<UNIQUENAME>"
$CONTAINERNAME="springappsterraform"
$TFSTATE_RG="springappsterraform"
```


Create a Resource Group:
```bash
az group create --name $TFSTATE_RG --location $REGION
```

Create a Storage Account:
```bash
az storage account create -n $STORAGEACCOUNTNAME -g $TFSTATE_RG -l $REGION --sku Standard_LRS
```

Create a Storage Container within the Storage Account:

```bash
az storage container-rm create --storage-account $STORAGEACCOUNTNAME --name $CONTAINERNAME -g $TFSTATE_RG
```

# Configure Variables for state management

Modify the variables within the "01 Remote Storage State configuration" section of the variable definitons file [parameters.tfvars](./parameters.tfvars).

Sample: 

```bash

##################################################
## 01 Remote Storage State configuration
##################################################

# Deployment state storage information
    state_sa_name  = "xxxx-enter-the-storage-account-name-xxxx"
    state_sa_rg    = "xxxx-enter-the-resource-group-here-xxxx"
    state_sa_container_name = "springappsterraform"


```

### Next step

:arrow_forward: [Deploy the Hub Virtual Network](./02-Hub-Network.md)