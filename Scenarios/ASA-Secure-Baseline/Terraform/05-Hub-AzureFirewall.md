# Create the Azure Firewall Resource

If you do not need an egress firewall skip to [Creation of Azure Spring Apps](./06-LZ-SpringApps.md)

If you brought your own hub resource (BYOH) and that hub already includes an Azure Firewall or 3rd party NVA which you would like to use, skip to [BYO Hub with Firewall](./05-Hub-BYO-Firewall-Routes.md).
Ensure that the Hub<>Spoke VNET peering has been completed.

The following will be created:
* Azure Firewall (azure_firewall.tf)
* User Defined Routes (azure_firewall_routes.tf)
* RBAC set on Routes for Azure Spring Apps Resource Provider (azure_firewall_routes_rbac.tf) see [docs](https://learn.microsoft.com/en-us/azure/spring-apps/how-to-create-user-defined-route-instance#add-a-role-for-an-azure-spring-apps-resource-provider)
* Required Firewall rules

Review and if needed, comment out and modify the variables within the "Optional - 05 Hub - AzureFirewall" section of the common variable definitons file [parameters.tfvars](./parameters.tfvars). 

Sample:

```bash
##################################################
## 05 Hub Azure Firewall
##################################################
    # azure_firewall_zones           = [1,2,3]


```
## Deploy the Azure Firewall and User Defined Routes

Navigate to the "/Scenarios/ASA-Secure-Baseline/Terraform/05-Hub-Firewall" directory. 

```bash
cd ../05-Hub-AzureFirewall
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

:arrow_forward: [Creation of Azure Spring Apps](./06-LZ-SpringApps.md)