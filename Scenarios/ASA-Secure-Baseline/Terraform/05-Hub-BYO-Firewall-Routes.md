# Create User Defined Routes for BYO Hub with Firewall

Follow this section to configure the User Defined Routes if you used an existing hub with an Azure Firewall or 3rd party Network Virtual Appliance (NVA). Azure Spring Apps requires the following Network and FQDN rules to be configured on the firewall: see [docs](https://learn.microsoft.com/en-us/azure/spring-apps/vnet-customer-responsibilities)

The following will be created:
* User Defined Routes (hub_byo_firewall_routes.tf)
* RBAC set on Routes for Azure Spring Apps Resource Provider (hub_byo_firewall_routes_rbac.tf) see [docs](https://learn.microsoft.com/en-us/azure/spring-apps/how-to-create-user-defined-route-instance#add-a-role-for-an-azure-spring-apps-resource-provider)


Comment out and modify the variable within the "Optional - 05 BYO Hub VNET / Bring your own Firewall/NVA" section of the common variable definitons file [parameters.tfvars](./parameters.tfvars) with the IP address of the AzFW/NVA.

Sample:

```bash
##################################################
## Optional - 05 BYO Hub VNET / Bring your own Firewall/NVA
##################################################
# Specify IP of existing Firewall/NVA in BYO Hub

   FW_IP = "10.0.1.4"

```
## Deploy the User Defined Routes

Navigate to the "/Scenarios/ASA-Secure-Baseline/Terraform/05-Hub-BYO-Firewall-Routes" directory. 

```bash
cd ../05-Hub-BYO-Firewall-Routes
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

:arrow_forward: [Creation of Azure Spring Apps](./06-LZ-SpringApps.md)