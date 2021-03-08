#!/bin/bash

#parameters
randomstring=$(LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | fold -w 13 | head -n 1)
#location='eastus' #location of Azure Spring Cloud Virtual Network
hub_vnet_name='vnet-hub' #Hub Virtual Network Name
hub_resource_group_name='sc-corp-rg' #Hub Virtual Network Resource Group 
log_analytics_workspace_name='law-'$randomstring #Name of Log Analytics Workspace used in script
hub_vnet_address_prefixes='10.9.0.0/16' #Hub Virtual Network Address Prefixes
firewal_subnet_prefix='10.9.0.0/24' #Address prefix of FW subnet 
jump_host_subnet_name='jumphost-subnet' #Hub Vnet jumphost subnet
jump_host_subnet_prefix='10.9.1.0/24' #Hub VNet jumphost subnet prefix
gateway_subnet_prefix='10.9.2.0/24' #Hub Vnet Virtual network gateway subnet name
bastion_subnet_prefix='10.9.4.0/24' #Hub VNet bastion prefix name
bastion_subnet_nsg='bastion-nsg'
application_gateway_subnet_name='application-gateway-subnet' #Hub Vnet application gateway subnet name
application_gateway_subnet_prefix='10.9.3.0/24' #Hub Vnet application GW subnet prefix
hub_vnet_jumphost_nsg_name='jumphost-subnet-nsg' #NSG Name for Hub Vnet jumphost VM
firewall_name='azfirewall-'$randomstring #Name of Azure firewall resource
firewall_public_ip_name='azure-firewall-ip' #Azure firewall public ip resource name
azure_bastion_ip_name='azure-bastion-ip' #Name of Azure Bastion public IP resource
azure_bastion_name='corp-bastion-svc' #Name of Azure Bastion service
azure_key_vault_name='akv-'$randomstring #Azure Key vault unique name
azure_mysql_name='mysql-'$randomstring #Azure MySql unique name 
azurespringcloud_vnet_resource_group_name='azurespringcloud-spoke-vnet-rg' #parameter for Azure Spring Cloud Virtual network resource group name
azurespringcloud_vnet_name='vnet-spoke' #parameter for Azure Spring Cloud Vnet name
azurespringcloud_vnet_address_prefixes='10.8.0.0/16' #address prefix of Azure Spring Cloud Virtual Network
azurespringcloud_service_runtime_subnet_prefix='10.8.0.0/24' #subnet prefix of Azure Spring Cloud service runtime subnet
azurespringcloud_service_runtime_subnet_name='sc-service-subnet' #subnet name of Azure Spring Cloud runtime subnet
azurespringcloud_app_subnet_prefix='10.8.1.0/24' #Azure Spring Cloud app subnet prefix 
azurespringcloud_app_subnet_name='sc-apps-subnet' #Azure Spring Cloud app subnet 
azure_spring_cloud_support_subnet_name='sc-support-subnet' #Azure Spring Cloud support subnet name
azure_spring_cloud_support_subnet_nsg='support-service-nsg' #Azure spring Cloud support subnet nsg
azure_spring_cloud_data_subnet_name='sc-data-subnet' #azure Spring Cloud data subnet name
azure_spring_cloud_data_subnet_nsg='data-service-nsg' #Azure spring Cloud support subnet nsg
azurespringcloud_data_subnet_prefix='10.8.2.0/24' #Azure Spring Cloud data subnet prefix
azurespringcloud_support_subnet_prefix='10.8.3.0/24' #Azure Spring Cloud support subnet prefix
azurespringcloud_resource_group_name='azspringcloud-rg' #Hub Virtual Network Resource Group name
azurespringcloud_service='spring-'$randomstring #Name of unique Spring Cloud resource
azurespringcloud_service_runtime_resource_group_name=$azurespringcloud_service'-runtime-rg' #Name of Azure Spring Cloud service runtime resource group	
azurespringcloud_app_resource_group_name=$azurespringcloud_service'-apps-rg' #Name of Azure Spring Cloud apps resource group
azurespringcloud_service_subnet_route_table_name='sc-service-subnet-routetable' #Azure Spring Cloud service subnet routetable name
azurespringcloud_app_subnet_route_table_name='sc-app-subnet-routetable' #Azure Spring Cloud app subnet routetable name


echo "Enter an Azure region for resource deployment: "
read region
location=$region

echo "Enter MySQL Db admin name: "
read mysqladmin
mysqldb_admin=$mysqladmin

echo "Enter MySql Db admin password: "
read -s mysqlpassword
mysqldb_password=$mysqlpassword

echo "Enter Jumphost VM admin name: "
read vmadmin
vm_admin=$vmadmin

echo "Enter Jumphost VM admin password: "
read -s vmpassword 
vm_password=$vmpassword


# Creates Hub resource Group
az group create --location ${location} --name ${hub_resource_group_name}

# Creates Log Analytics Workspace 
az monitor log-analytics workspace create \
    --resource-group ${hub_resource_group_name} \
    --workspace-name ${log_analytics_workspace_name} \
    --location ${location} \
    --sku PerGB2018

# Creates NSG for jump box VM and Azure Bastion subnets
az network nsg create \
    --resource-group ${hub_resource_group_name} \
    --name ${hub_vnet_jumphost_nsg_name}

az network nsg create \
    --resource-group ${hub_resource_group_name} \
    --name ${bastion_subnet_nsg}

az network nsg rule create \
    --resource-group ${hub_resource_group_name} \
    --nsg-name ${bastion_subnet_nsg} \
    --name AllowHttpsInbound \
    --priority 100 \
    --source-address-prefixes Internet \
    --source-port-ranges '*' \
    --destination-address-prefixes '*' \
    --destination-port-ranges 443 \
    --access Allow \
    --protocol Tcp

az network nsg rule create \
    --resource-group ${hub_resource_group_name} \
    --nsg-name ${bastion_subnet_nsg} \
    --name AllowGatewayManagerInbound \
    --priority 110 \
    --source-address-prefixes GatewayManager \
    --source-port-ranges '*' \
    --destination-address-prefixes '*' \
    --destination-port-ranges 443 \
    --access Allow \
    --protocol Tcp

az network nsg rule create \
    --resource-group ${hub_resource_group_name} \
    --nsg-name ${bastion_subnet_nsg} \
    --name AllowAzureLoadbalancerInbound \
    --priority 120 \
    --source-address-prefixes AzureLoadBalancer \
    --source-port-ranges '*' \
    --destination-address-prefixes '*' \
    --destination-port-ranges 443 \
    --access Allow \
    --protocol Tcp

az network nsg rule create \
    --resource-group ${hub_resource_group_name} \
    --nsg-name ${bastion_subnet_nsg} \
    --name AllowBastionHostCommunicationInbound \
    --priority 130 \
    --source-address-prefixes VirtualNetwork \
    --source-port-ranges '*' \
    --destination-address-prefixes VirtualNetwork \
    --destination-port-ranges 8080 5701 \
    --access Allow \
    --protocol '*'

az network nsg rule create \
    --resource-group ${hub_resource_group_name} \
    --nsg-name ${bastion_subnet_nsg} \
    --name AllowRdpSshOutbound \
    --priority 100 \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-address-prefixes VirtualNetwork \
    --destination-port-ranges 3389 22 \
    --access Allow \
    --direction Outbound \
    --protocol '*'

az network nsg rule create \
    --resource-group ${hub_resource_group_name} \
    --nsg-name ${bastion_subnet_nsg} \
    --name AllowBastionHostCommunicationOutbound \
    --priority 110 \
    --source-address-prefixes VirtualNetwork \
    --source-port-ranges '*' \
    --destination-address-prefixes VirtualNetwork \
    --destination-port-ranges 8080 5701 \
    --access Allow \
    --direction Outbound \
    --protocol '*'

az network nsg rule create \
    --resource-group ${hub_resource_group_name} \
    --nsg-name ${bastion_subnet_nsg} \
    --name AllowAzureCloudOutbound \
    --priority 120 \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-address-prefixes AzureCloud \
    --destination-port-ranges 443 \
    --access Allow \
    --direction Outbound \
    --protocol '*'

az network nsg rule create \
    --resource-group ${hub_resource_group_name} \
    --nsg-name ${bastion_subnet_nsg} \
    --name AllowGetSessionInformation \
    --priority 130 \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-address-prefixes Internet \
    --destination-port-ranges 80 \
    --access Allow \
    --direction Outbound \
    --protocol '*'

# Creates Hub Vnet and subnets for Azure Firewall, Azure Application Gateway, and centralized services
az network vnet create \
    --name ${hub_vnet_name} \
    --resource-group ${hub_resource_group_name} \
    --location ${location} \
    --address-prefixes ${hub_vnet_address_prefixes}

az network vnet subnet create \
    --name 'AzureFirewallSubnet' \
    --resource-group ${hub_resource_group_name} \
    --vnet-name ${hub_vnet_name} \
    --address-prefix ${firewal_subnet_prefix}

az network vnet subnet create \
    --name ${jump_host_subnet_name} \
    --resource-group ${hub_resource_group_name}  \
    --vnet-name ${hub_vnet_name} \
    --address-prefix ${jump_host_subnet_prefix} \
    --network-security-group ${hub_vnet_jumphost_nsg_name}

az network vnet subnet create \
    --name 'GatewaySubnet' \
    --resource-group ${hub_resource_group_name} \
    --vnet-name ${hub_vnet_name} \
    --address-prefix ${gateway_subnet_prefix}

az network vnet subnet create \
    --name ${application_gateway_subnet_name} \
    --resource-group ${hub_resource_group_name} \
    --vnet-name ${hub_vnet_name} \
    --address-prefix ${application_gateway_subnet_prefix}

az network vnet subnet create \
    --name AzureBastionSubnet \
    --resource-group ${hub_resource_group_name} \
    --vnet-name ${hub_vnet_name} \
    --address-prefix ${bastion_subnet_prefix} \
    --network-security-group ${bastion_subnet_nsg}


# Creates public IP and Azure Bastion in hub Vnet
az network public-ip create --resource-group ${hub_resource_group_name} --name ${azure_bastion_ip_name} --sku Standard --location ${location}

az network bastion create --resource-group ${hub_resource_group_name} --name ${azure_bastion_name} --public-ip-address ${azure_bastion_ip_name} --vnet-name ${hub_vnet_name} --location ${location}


# creates Jumphost VM
az vm create \
    --resource-group ${hub_resource_group_name} \
    --name jumphostvm \
    --image MicrosoftWindowsServer:WindowsServer:2019-Datacenter:latest \
    --size Standard_DS3_v2 \
    --admin-username $vm_admin \
    --admin-password $vm_password \
    --vnet-name ${hub_vnet_name} \
    --subnet ${jump_host_subnet_name} \
    --public-ip-address "" \
    --nsg ""

# Creates custom script extension for jumphost VM 
az vm extension set \
    --name CustomScriptExtension \
    --publisher Microsoft.Compute \
    --vm-name jumphostvm \
    --resource-group ${hub_resource_group_name} \
    --protected-settings '{"commandToExecute": "powershell.exe -Command \"./DeployDeveloperConfig.ps1; exit 0;\""}' \
    --settings '{"fileUris": ["https://raw.githubusercontent.com/Azure/azure-spring-cloud-reference-architecture/main/terraform/modules/jump_host/DeployDeveloperConfig.ps1","https://raw.githubusercontent.com/Azure/azure-spring-cloud-reference-architecture/main/deployPetClinicApp.ps1"]}'

# creates Azure Firewall instance, public IP and Azure Firewall IP Configuration
az network firewall create \
    --name ${firewall_name} \
    --resource-group ${hub_resource_group_name} \
    --location ${location} \
    --enable-dns-proxy true
az network public-ip create \
    --name ${firewall_public_ip_name} \
    --resource-group ${hub_resource_group_name} \
    --location ${location} \
    --allocation-method static \
    --sku standard
az network firewall ip-config create \
    --firewall-name ${firewall_name} \
    --name FW-config \
    --public-ip-address ${firewall_public_ip_name} \
    --resource-group ${hub_resource_group_name}\
    --vnet-name ${hub_vnet_name}
az network firewall update \
    --name ${firewall_name}  \
    --resource-group ${hub_resource_group_name}
firewall_private_ip="$(az network firewall ip-config list -g ${hub_resource_group_name} -f ${firewall_name} --query "[?name=='FW-config'].privateIpAddress" --output tsv)"

# create Azure Firewall network rules
az network firewall network-rule create \
    --collection-name SpringCloudAccess \
    --destination-ports 123 \
    --firewall-name ${firewall_name} \
    --name NtpQuery \
    --protocols UDP \
    --resource-group ${hub_resource_group_name} \
    --action Allow \
    --destination-fqdns "ntp.ubuntu.com" \
    --source-addresses ${azurespringcloud_app_subnet_prefix} ${azurespringcloud_service_runtime_subnet_prefix} \
    --priority 100

az network firewall network-rule create \
    --collection-name SpringCloudAccess \
    --destination-ports 443 \
    --description "Allows access to Spring Cloud Management plane" \
    --firewall-name ${firewall_name} \
    --name SpringMgmt \
    --protocols TCP \
    --resource-group ${hub_resource_group_name} \
    --destination-addresses "AzureCloud" \
    --source-addresses ${azurespringcloud_app_subnet_prefix} ${azurespringcloud_service_runtime_subnet_prefix}    

az network firewall network-rule create \
    --collection-name SpringCloudAccess \
    --destination-ports 9000 \
    --description "Allows underlining Kubernetes cluster management for TCP traffic" \
    --firewall-name ${firewall_name} \
    --name K8sMgmtTcp \
    --protocols TCP \
    --resource-group ${hub_resource_group_name} \
    --destination-addresses "AzureCloud" \
    --source-addresses ${azurespringcloud_app_subnet_prefix} ${azurespringcloud_service_runtime_subnet_prefix}

 az network firewall network-rule create \
    --collection-name SpringCloudAccess \
    --destination-ports 1194 \
    --description "Allows underlining Kubernetes cluster management for TCP traffic" \
    --firewall-name ${firewall_name} \
    --name K8sMgmtUdp \
    --protocols UDP \
    --resource-group ${hub_resource_group_name} \
    --destination-addresses "AzureCloud" \
    --source-addresses ${azurespringcloud_app_subnet_prefix} ${azurespringcloud_service_runtime_subnet_prefix}

 az network firewall network-rule create \
    --collection-name SpringCloudAccess \
    --destination-ports 443 \
    --description "Allows access to Azure Container Registry" \
    --firewall-name ${firewall_name} \
    --name AzureContainerRegistry \
    --protocols TCP \
    --resource-group ${hub_resource_group_name} \
    --destination-addresses "AzureContainerRegistry" \
    --source-addresses ${azurespringcloud_app_subnet_prefix} ${azurespringcloud_service_runtime_subnet_prefix}

 az network firewall network-rule create \
    --collection-name SpringCloudAccess \
    --destination-ports 445 \
    --description "Allows access to Azure Storage" \
    --firewall-name ${firewall_name} \
    --name AzureStorage \
    --protocols TCP \
    --resource-group ${hub_resource_group_name} \
    --destination-addresses "Storage" \
    --source-addresses ${azurespringcloud_app_subnet_prefix} ${azurespringcloud_service_runtime_subnet_prefix}

# Creates Azure Firewall application rules
az network firewall application-rule create \
    --collection-name AllowSpringCloudWebAccess \
    --firewall-name ${firewall_name} \
    --name AllowAks \
    --description "Allow Access for Azure Kubernetes Service" \
    --protocols https=443 \
    --resource-group ${hub_resource_group_name} \
    --source-addresses ${azurespringcloud_app_subnet_prefix} ${azurespringcloud_service_runtime_subnet_prefix} \
    --fqdn-tags "AzureKubernetesService" \
    --priority 100 \
    --action allow
 
az network firewall application-rule create \
    --collection-name AllowSpringCloudWebAccess \
    --firewall-name ${firewall_name} \
    --name UbuntuLibraries \
    --description "Allow Access for Ubuntu Libraries" \
    --protocols https=443 \
    --resource-group ${hub_resource_group_name} \
    --source-addresses ${azurespringcloud_app_subnet_prefix} ${azurespringcloud_service_runtime_subnet_prefix} \
    --target-fqdns "api.snapcraft.io" "motd.ubuntu.com"

az network firewall application-rule create \
    --collection-name MicrosoftCRLrules \
    --firewall-name ${firewall_name} \
    --name CRLLibraries \
    --description "Required CRL Rules" \
    --protocols http=80 \
    --resource-group ${hub_resource_group_name} \
    --source-addresses ${azurespringcloud_app_subnet_prefix} ${azurespringcloud_service_runtime_subnet_prefix} \
    --target-fqdns  "crl.microsoft.com" "mscrl.microsoft.com" "crl3.digicert.com" "ocsp.digicert.com" \
    --priority 110 \
    --action allow

az network firewall application-rule create \
    --collection-name MicrosoftBlobRules \
    --firewall-name ${firewall_name} \
    --name Blob_rules \
    --description "Required Azure Storage Rules" \
    --protocols https=443 \
    --resource-group ${hub_resource_group_name} \
    --source-addresses ${azurespringcloud_app_subnet_prefix} ${azurespringcloud_service_runtime_subnet_prefix} \
    --target-fqdns  "*.blob.core.windows.net" \
    --priority 120 \
    --action allow

az network firewall application-rule create \
    --collection-name DatabaseClamavRule \
    --firewall-name ${firewall_name} \
    --name database_clamav_rules \
    --description "Required database clamav rules" \
    --protocols https=443 \
    --resource-group ${hub_resource_group_name} \
    --source-addresses ${azurespringcloud_app_subnet_prefix} ${azurespringcloud_service_runtime_subnet_prefix} \
    --target-fqdns  "database.clamav.net" \
    --priority 130 \
    --action allow

az network firewall application-rule create \
    --collection-name GithubRule \
    --firewall-name ${firewall_name} \
    --name Github_Rules \
    --description "Required Github rules" \
    --protocols https=443 \
    --resource-group ${hub_resource_group_name} \
    --source-addresses ${azurespringcloud_app_subnet_prefix} ${azurespringcloud_service_runtime_subnet_prefix} \
    --target-fqdns  "github.com" \
    --priority 140 \
    --action allow

az network firewall application-rule create \
    --collection-name MicrosoftMetricRule \
    --firewall-name ${firewall_name} \
    --name Microsoft_metrics \
    --description "Required metric rules" \
    --protocols https=443 \
    --resource-group ${hub_resource_group_name} \
    --source-addresses ${azurespringcloud_app_subnet_prefix} ${azurespringcloud_service_runtime_subnet_prefix} \
    --target-fqdns  "*.prod.microsoftmetrics.com" \
    --priority 150 \
    --action allow


az network firewall application-rule create \
    --collection-name AKSACSRule \
    --firewall-name ${firewall_name} \
    --name AKS_acs_rules \
    --description "Required AKS acs rules" \
    --protocols https=443 \
    --resource-group ${hub_resource_group_name} \
    --source-addresses ${azurespringcloud_app_subnet_prefix} ${azurespringcloud_service_runtime_subnet_prefix} \
    --target-fqdns  "acs-mirror.azureedge.net" \
    --priority 160 \
    --action allow


az network firewall application-rule create \
    --collection-name MicrosoftLoginRule \
    --firewall-name ${firewall_name} \
    --name AKS_acs_rules \
    --description "Required login rules" \
    --protocols https=443 \
    --resource-group ${hub_resource_group_name} \
    --source-addresses ${azurespringcloud_app_subnet_prefix} ${azurespringcloud_service_runtime_subnet_prefix} \
    --target-fqdns  "login.microsoftonline.com" \
    --priority 170 \
    --action allow

# Creates Diagnostic Settings to send logs and metrics to Log Analytics Workspace
az monitor diagnostic-settings create \
    --name "ToLAW" \
    --resource ${firewall_name} \
    --resource-group ${hub_resource_group_name} \
    --resource-type Microsoft.Network/azureFirewalls \
    --workspace ${log_analytics_workspace_name} \
    --logs '[
        {
            "category": "AzureFirewallApplicationRule",
            "enabled": true,
            "retentionPolicy": {
                "enabled": false,
                "days": 0
                }
        },
        {
            "category": "AzureFirewallNetworkRule",
            "enabled": true,
            "retentionPolicy": {
                "enabled": false,
                "days": 0
                }
        },
        {
            "category": "AzureFirewallDnsProxy",
            "enabled": true,
            "retentionPolicy": {
                "enabled": false,
                "days": 0
                }
        }   
    ]' \
    --metrics '[
        {
            "category": "AllMetrics",
            "enabled": true,
            "retentionPolicy": {
                "enabled": false,
                "days": 0
                }
        }
    ]'



# Creates NSG for Azure Spring Cloud data and support subnets
az network nsg create \
    --resource-group ${hub_resource_group_name} \
    --name ${azure_spring_cloud_support_subnet_nsg}

az network nsg create \
    --resource-group ${hub_resource_group_name} \
    --name ${azure_spring_cloud_data_subnet_nsg}


#Creates routetables and default route to be used with Azure Spring Cloud
az network route-table create \
    --name ${azurespringcloud_service_subnet_route_table_name} \
    --resource-group ${hub_resource_group_name}

az network route-table route create \
    --resource-group ${hub_resource_group_name} \
    --route-table-name ${azurespringcloud_service_subnet_route_table_name} \
    --name default \
    --address-prefix 0.0.0.0/0 \
    --next-hop-type VirtualAppliance \
    --next-hop-ip-address ${firewall_private_ip}

az network route-table create \
    --name ${azurespringcloud_app_subnet_route_table_name} \
    --resource-group ${hub_resource_group_name}

az network route-table route create \
    --resource-group ${hub_resource_group_name} \
    --route-table-name ${azurespringcloud_app_subnet_route_table_name} \
    --name default \
    --address-prefix 0.0.0.0/0 \
    --next-hop-type VirtualAppliance \
    --next-hop-ip-address ${firewall_private_ip}

app_rt_id=$(az network route-table show \
    --resource-group ${hub_resource_group_name} \
    --name ${azurespringcloud_app_subnet_route_table_name} \
    --query id --output tsv )

service_rt_id=$(az network route-table show \
    --resource-group ${hub_resource_group_name} \
    --name ${azurespringcloud_service_subnet_route_table_name} \
    --query id --output tsv )


#Grant Azure Spring Cloud Resoure Provider Owner role to route tables
az role assignment create \
    --role "Owner" \
    --scope ${service_rt_id} \
    --assignee e8de9221-a19c-4c81-b814-fd37c6caf9d2

az role assignment create \
    --role "Owner" \
    --scope ${app_rt_id} \
    --assignee e8de9221-a19c-4c81-b814-fd37c6caf9d2



#Creates Azure Spring Cloud spoke Vnet and subnets
az network vnet create \
    --name ${azurespringcloud_vnet_name} \
    --resource-group ${hub_resource_group_name} \
    --location ${location} \
    --address-prefixes ${azurespringcloud_vnet_address_prefixes} \
    --dns-servers ${firewall_private_ip}


az network vnet subnet create  \
    --name ${azurespringcloud_service_runtime_subnet_name} \
    --resource-group ${hub_resource_group_name} \
    --vnet-name ${azurespringcloud_vnet_name} \
    --address-prefix ${azurespringcloud_service_runtime_subnet_prefix} \
    --route-table ${service_rt_id}



az network vnet subnet create \
    --name ${azurespringcloud_app_subnet_name} \
    --resource-group ${hub_resource_group_name} \
    --vnet-name ${azurespringcloud_vnet_name} \
    --address-prefix ${azurespringcloud_app_subnet_prefix} \
    --route-table ${app_rt_id}


az network vnet subnet create \
    --name ${azure_spring_cloud_data_subnet_name} \
    --resource-group ${hub_resource_group_name} \
    --vnet-name ${azurespringcloud_vnet_name} \
    --address-prefix ${azurespringcloud_data_subnet_prefix} \
    --network-security-group ${azure_spring_cloud_data_subnet_nsg}

az network vnet subnet create \
    --name ${azure_spring_cloud_support_subnet_name} \
    --resource-group ${hub_resource_group_name} \
    --vnet-name ${azurespringcloud_vnet_name} \
    --address-prefix ${azurespringcloud_support_subnet_prefix} \
    --network-security-group ${azure_spring_cloud_support_subnet_nsg} \
    --disable-private-endpoint-network-policies true 


#Get Resource ID  for Azure Spring Cloud Vnet
azurespringcloud_vnet_id=$(az network vnet show \
    --resource-group ${hub_resource_group_name} \
    --name ${azurespringcloud_vnet_name} \
    --query id --out tsv)

#Get Resource ID for Hub Vnet
hub_vnet_id=$(az network vnet show \
    --resource-group ${hub_resource_group_name} \
    --name ${hub_vnet_name} \
    --query id --out tsv)

# Assign Azure Spring Cloud Resource Provider owner role to Azure Spring Cloud spoke Vnet
az role assignment create \
    --role "Owner" \
    --scope ${azurespringcloud_vnet_id} \
    --assignee e8de9221-a19c-4c81-b814-fd37c6caf9d2



# Creates peering from Azure Spring Cloud vnet to hub vnet
az network vnet peering create \
    --name azurespringcloud_vnet_to_hub_vnet \
    --resource-group ${hub_resource_group_name} \
    --vnet-name ${azurespringcloud_vnet_name} \
    --remote-vnet ${hub_vnet_name} \
    --allow-vnet-access




# Creates peering from Hub Vnet to Azure Spring Cloud Spoke Vnet
az network vnet peering create \
    --name hub_vnet_to_azurespringcloud_vnet \
    --resource-group ${hub_resource_group_name} \
    --vnet-name ${hub_vnet_name} \
    --remote-vnet ${azurespringcloud_vnet_name} \
    --allow-vnet-access



# Creates Azure Spring Cloud key vault, sets access policy of provided UPN, and creates AKV Private Endpoint
az keyvault create --name ${azure_key_vault_name} \
	--resource-group ${hub_resource_group_name} \
	--location ${location} \
	--no-self-perms false \
    --default-action Deny \
    --enabled-for-deployment true \
    --bypass AzureServices


#az keyvault set-policy --name ${azure_key_vault_name} \
	#--object-id $admin_object_id  \
	#--key-permissions backup create decrypt delete encrypt get import list purge recover restore sign unwrapKey update verify wrapKey \
	#--secret-permissions backup delete get list purge recover restore set \
	#--certificate-permissions backup create delete deleteissuers get getissuers import list listissuers managecontacts manageissuers purge recover restore setissuers update


akv_id=$(az keyvault show -g ${hub_resource_group_name} --name ${azure_key_vault_name} --query id --output tsv)

az network private-endpoint create \
    --name ${azure_key_vault_name}"-endpoint" \
    --resource-group ${hub_resource_group_name} \
    --vnet-name ${azurespringcloud_vnet_name} \
    --subnet ${azure_spring_cloud_support_subnet_name} \
    --private-connection-resource-id ${akv_id} \
    --group-id vault \
    --connection-name "kv-private-link-connection"

# Creates the Private DNS for Azure Key Vault
az network private-dns zone create \
    --resource-group ${hub_resource_group_name} \
    --name privatelink.vaultcore.azure.net

akv_dns_id=$(az network private-dns zone show --resource-group ${hub_resource_group_name} --name privatelink.vaultcore.azure.net --query id --output tsv)

az network private-endpoint dns-zone-group create \
    --endpoint-name ${azure_key_vault_name}"-endpoint" \
    --name privatelink.vaultcore.azure.net \
    --private-dns-zone $akv_dns_id \
    --zone-name privatelink.vaultcore.azure.net \
    --resource-group ${hub_resource_group_name}


#Creates virtual network link between Azure Key Vault Private DNS Zone and Azure Spring Cloud Vnet
az network private-dns link vnet create \
    --resource-group ${hub_resource_group_name} \
    --name link-to-${azurespringcloud_vnet_name} \
    --zone-name privatelink.vaultcore.azure.net \
    --virtual-network ${azurespringcloud_vnet_id} \
    --registration-enabled false

# Creates virtual network link between Private DNS Zone and Hub VNet
az network private-dns link vnet create \
    --resource-group ${hub_resource_group_name} \
    --name link-to-${hub_vnet_name} \
    --zone-name privatelink.vaultcore.azure.net \
    --virtual-network ${hub_vnet_id}\
    --registration-enabled false



# Creates MySql Db and MySql Db private endpoint
az mysql server create \
	--name ${azure_mysql_name} \
	--resource-group ${hub_resource_group_name} \
	--location ${location} \
	--admin-user $mysqldb_admin \
	--admin-password $mysqldb_password \
	--sku-name GP_Gen5_2 \
	--backup-retention 7 \
	--geo-redundant-backup Disabled \
	--storage-size 51200 \
    --public-network-access Disabled \
    --ssl-enforcement Disabled

mysql_id=$(az mysql server show -g ${hub_resource_group_name} --name ${azure_mysql_name} --query id --output tsv)

az network private-endpoint create \
    --name ${azure_mysql_name}"-endpoint" \
    --resource-group ${hub_resource_group_name} \
    --vnet-name ${azurespringcloud_vnet_name} \
    --subnet ${azure_spring_cloud_support_subnet_name} \
    --private-connection-resource-id ${mysql_id} \
    --group-id mysqlServer \
    --connection-name "mysql-private-link-connection"


# Creates Private DNS for MySql Db
az network private-dns zone create \
    --resource-group ${hub_resource_group_name} \
    --name privatelink.mysql.database.azure.com

mysql_dns_id=$(az network private-dns zone show --resource-group ${hub_resource_group_name} --name privatelink.mysql.database.azure.com --query id --output tsv)

az network private-endpoint dns-zone-group create \
    --endpoint-name ${azure_mysql_name}"-endpoint" \
    --name privatelink.mysql.database.azure.com \
    --private-dns-zone $mysql_dns_id \
    --zone-name privatelink.mysql.database.azure.com \
    --resource-group ${hub_resource_group_name}

# Creates virtual network link between MySql Db Private DNS Zone and Azure Spring Cloud VNet
az network private-dns link vnet create \
    --resource-group ${hub_resource_group_name} \
    --name link-to-${azurespringcloud_vnet_name} \
    --zone-name privatelink.mysql.database.azure.com \
    --virtual-network ${azurespringcloud_vnet_id} \
    --registration-enabled false

# Creates virtual network link between Private DNS Zone and Hub VNet
az network private-dns link vnet create \
    --resource-group ${hub_resource_group_name} \
    --name link-to-${hub_vnet_name} \
    --zone-name privatelink.mysql.database.azure.com \
    --virtual-network ${hub_vnet_id} \
    --registration-enabled false


#Gets id of Azure Spring Cloud apps subnet
apps_subnet_id=$(az network vnet subnet show \
    --resource-group ${hub_resource_group_name} \
    --vnet-name ${azurespringcloud_vnet_name} \
    --name ${azurespringcloud_app_subnet_name} \
    --query id --output tsv)



# Gets id of Azure Spring Cloud service runtime subnet 
service_runtime_subnet_id=$(az network vnet subnet show \
    --resource-group ${hub_resource_group_name} \
    --vnet-name ${azurespringcloud_vnet_name} \
    --name ${azurespringcloud_service_runtime_subnet_name} \
    --query id --output tsv)





# Creates Azure Spring Cloud instance
az spring-cloud create \
    --name ${azurespringcloud_service} \
    --resource-group ${hub_resource_group_name} \
    --location ${location} \
    --app-network-resource-group ${azurespringcloud_app_resource_group_name} \
    --service-runtime-network-resource-group ${azurespringcloud_service_runtime_resource_group_name} \
    --vnet ${azurespringcloud_vnet_id} \
    --reserved-cidr-range 10.0.0.0/16,10.1.0.0/16,10.2.0.1/16 \
    --service-runtime-subnet ${service_runtime_subnet_id} \
    --app-subnet ${apps_subnet_id}

# Gets LAW resource id and creates diagnostic settings to send logs and metrics to Log Analytics Workspace
law_id=$(az monitor log-analytics workspace show --resource-group ${hub_resource_group_name} --workspace-name ${log_analytics_workspace_name} --query id --output tsv)


az monitor diagnostic-settings create \
    --name "ToLAW" \
    --resource ${azurespringcloud_service} \
    --resource-group ${hub_resource_group_name} \
    --resource-type Microsoft.AppPlatform/Spring \
    --workspace ${law_id} \
    --logs '[
        {
            "category": "ApplicationConsole",
            "enabled": true,
            "retentionPolicy": {
                "enabled": false,
                "days": 0
                }
        },
        {
            "category": "SystemLogs",
            "enabled": true,
            "retentionPolicy": {
                "enabled": false,
                "days": 0
                }
        }   
    ]' \
    --metrics '[
        {
            "category": "AllMetrics",
            "enabled": true,
            "retentionPolicy": {
                "enabled": false,
                "days": 0
                }
        }
    ]'



#Creates Private DNS Zone for Azure Spring Cloud
az network private-dns zone create \
    --resource-group ${hub_resource_group_name} \
    --name private.azuremicroservices.io



# Creates virtual network link between Private DNS Zone and Azure Spring Cloud VNet
az network private-dns link vnet create \
    --resource-group ${hub_resource_group_name} \
    --name link-to-${azurespringcloud_vnet_name} \
    --zone-name private.azuremicroservices.io \
    --virtual-network ${azurespringcloud_vnet_id} \
    --registration-enabled false

# Creates virtual link between Private DNS Zone and Hub VNet
az network private-dns link vnet create \
    --resource-group ${hub_resource_group_name} \
    --name link-to-${hub_vnet_name} \
    --zone-name private.azuremicroservices.io \
    --virtual-network ${hub_vnet_id}\
    --registration-enabled false



#Get Azure Spring Cloud service runtime subnet internal load balancer private IP address and add private IP to Azure Spring Cloud private DNS zone
azurespringcloud_internal_lb_private_ip=$(az network lb show --name kubernetes-internal \
    --resource-group ${azurespringcloud_service_runtime_resource_group_name} \
    --query frontendIpConfigurations[*].privateIpAddress --out tsv )


az network private-dns record-set a add-record \
    --resource-group ${hub_resource_group_name} \
    --zone-name private.azuremicroservices.io \
    --record-set-name '*' \
    --ipv4-address ${azurespringcloud_internal_lb_private_ip}