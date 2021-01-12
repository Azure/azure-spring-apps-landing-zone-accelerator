#!/bin/bash

#parameters
randomstring=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 7 | head -n 1)
location='eastus' #location of Azure Spring Cloud Virtual Network
hub_vnet_name='hub-vnet' #Hub Virtual Network Name
hub_resource_group_name='hub-rg' #Hub Virtual Network Resource Group 
log_analytics_workspace_name='law-'$randomstring #Name of Log Analytics Workspace used in script
hub_vnet_address_prefixes='10.9.0.0/16' #Hub Virtual Network Address Prefixes
firewal_subnet_prefix='10.9.0.0/24' #Address prefix of FW subnet 
centralized_services_subnet_name='centralized-services-subnet' #Hub Vnet centralized services subnet
centralized_services_subnet_prefix='10.9.1.0/24' #Hub VNet centralized services subnet prefix
gateway_subnet_prefix='10.9.2.0/24' #Hub Vnet Virtual network gateway subnet name
bastion_subnet_prefix='10.9.4.0/24' #Hub VNet bastion prefix name
bastion_subnet_nsg='bastion-nsg'
application_gateway_subnet_name='application-gateway-subnet' #Hub Vnet application gateway subnet name
application_gateway_subnet_prefix='10.9.3.0/24' #Hub Vnet application GW subnet prefix
hub_vnet_jumpbox_nsg_name='hub-vnet-jumpbox-nsg' #NSG Name for Hub Vnet Jumpbox VM
firewall_name='azfirewall' #Name of Azure firewall resource
firewall_public_ip_name='azfirewall-pip' #Azure firewall public ip resource name
azure_key_vault_name='akv-'$randomstring #Azure Key vault unique name
azure_mysql_name='mysql-'$randomstring #Azure MySql unique name 
azurespringcloud_vnet_resource_group_name='azurespringcloud-spoke-vnet-rg' #parameter for Azure Spring Cloud Virtual network resource group name
azurespringcloud_vnet_name='azurespringcloud-spoke-vnet' #parameter for Azure Spring Cloud Vnet name
azurespringcloud_vnet_address_prefixes='10.8.0.0/16' #address prefix of Azure Spring Cloud Virtual Network
azurespringcloud_service_runtime_subnet_prefix='10.8.0.0/24' #subnet prefix of Azure Spring Cloud service runtime subnet
azurespringcloud_service_runtime_subnet_name='service-runtime-subnet' #subnet name of Azure Spring Cloud runtime subnet
azurespringcloud_app_subnet_prefix='10.8.1.0/24' #Azure Spring Cloud app subnet prefix 
azurespringcloud_app_subnet_name='apps-subnet' #Azure Spring Cloud app subnet 
azure_spring_cloud_support_subnet_name='support-subnet' #Azure Spring Cloud support subnet name
azure_spring_cloud_support_subnet_nsg='support-nsg' #Azure spring Cloud support subnet nsg
azure_spring_cloud_data_subnet_name='data-subnet' #azure Spring Cloud data subnet name
azure_spring_cloud_data_subnet_nsg='data-nsg' #Azure spring Cloud support subnet nsg
azurespringcloud_data_subnet_prefix='10.8.2.0/24' #Azure Spring Cloud data subnet prefix
azurespringcloud_support_subnet_prefix='10.8.3.0/24' #Azure Spring Cloud support subnet prefix
azurespringcloud_resource_group_name='azspringcloud-rg' #Hub Virtual Network Resource Group name
azurespringcloud_service='azspringcloud-'$randomstring #Name of unique Spring Cloud resource
azurespringcloud_service_runtime_resource_group_name=$azurespringcloud_service'-service-runtime-rg' #Name of Azure Spring Cloud service runtime resource group	
azurespringcloud_app_resource_group_name=$azurespringcloud_service'-apps-rg' #Name of Azure Spring Cloud apps resource group

echo "Enter full UPN of Key Vault Admin: "
read userupn
admin_object_id=$(az ad user show --id $userupn --query objectId --output tsv)

echo "Enter MySql Db admin name: "
read mysqladmin
mysqldb_admin=$mysqladmin

echo "Enter MySql Db admin password: "
read mysqlpassword
mysqldb_password=$mysqlpassword

echo "Enter Jumpbox VM admin name: "
read vmadmin
vm_admin=$vmadmin

echo "Enter Jumpbox VM admin password: "
read vmpassword
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
    --name ${hub_vnet_jumpbox_nsg_name}

az network nsg create \
    --resource-group ${hub_resource_group_name} \
    --name ${bastion_subnet_nsg}

az network nsg rule create \
    --resource-group ${hub_resource_group_name} \
    --nsg-name ${bastion_subnet_nsg} \
    --name AllowHttpsInbound \
    --priority 100 \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-address-prefixes Internet \
    --destination-port-ranges 443 \
    --access Allow \
    --protocol Tcp

az network nsg rule create \
    --resource-group ${hub_resource_group_name} \
    --nsg-name ${bastion_subnet_nsg} \
    --name AllowGatewayManagerInbound \
    --priority 110 \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-address-prefixes GatewayManager \
    --destination-port-ranges 443 \
    --access Allow \
    --protocol Tcp

az network nsg rule create \
    --resource-group ${hub_resource_group_name} \
    --nsg-name ${bastion_subnet_nsg} \
    --name AllowAzureLoadbalancerInbound \
    --priority 120 \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-address-prefixes AzureLoadBalancer \
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
    --name ${centralized_services_subnet_name} \
    --resource-group ${hub_resource_group_name}  \
    --vnet-name ${hub_vnet_name} \
    --address-prefix ${centralized_services_subnet_prefix} \
    --network-security-group ${hub_vnet_jumpbox_nsg_name}

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
az network public-ip create --resource-group ${hub_resource_group_name} --name azbastion-pip --sku Standard --location ${location}

az network bastion create --resource-group ${hub_resource_group_name} --name azbastion --public-ip-address azbastion-pip --vnet-name ${hub_vnet_name} --location ${location}


# creates Jumpbox VM
az vm create \
    --resource-group ${hub_resource_group_name} \
    --name jumpbox \
    --image win2019datacenter \
    --admin-username $vm_admin \
    --admin-password $vm_password \
    --vnet-name ${hub_vnet_name} \
    --subnet ${centralized_services_subnet_name} \
    --public-ip-address "" \
    --nsg ""

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
    --address-prefix ${azurespringcloud_service_runtime_subnet_prefix} 


az network vnet subnet create \
    --name ${azurespringcloud_app_subnet_name} \
    --resource-group ${hub_resource_group_name} \
    --vnet-name ${azurespringcloud_vnet_name} \
    --address-prefix ${azurespringcloud_app_subnet_prefix}


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
	--no-self-perms \
    --default-action Deny \
    --enabled-for-deployment true \
    --bypass AzureServices


az keyvault set-policy --name ${azure_key_vault_name} \
	--object-id $admin_object_id  \
	--key-permissions backup create decrypt delete encrypt get import list purge recover restore sign unwrapKey update verify wrapKey \
	--secret-permissions backup delete get list purge recover restore set \
	--certificate-permissions backup create delete deleteissuers get getissuers import list listissuers managecontacts manageissuers purge recover restore setissuers update


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
	--sku-name GP_Gen5_2
	--ssl-enforcement Disabled \
	--backup-retention 7 \
	--geo-redundant-backup Disabled \
    --minimal-tls-version TLS1_2 \
	--storage-size 51200 \
    --public-network-access Disabled

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
    --virtual-network ${hub_vnet_id}\
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


#Creates Azure Spring Cloud resource group
az group create --location ${location} --name ${azurespringcloud_resource_group_name}


# Creates Azure Spring Cloud instance
az spring-cloud create \
    --name ${azurespringcloud_service} \
    --resource-group ${azurespringcloud_resource_group_name} \
    --location ${location} \
    --app-network-resource-group ${azurespringcloud_app_resource_group_name} \
    --service-runtime-network-resource-group ${azurespringcloud_service_runtime_resource_group_name} \
    --vnet ${azurespringcloud_vnet_id} \
    --service-runtime-subnet ${service_runtime_subnet_id} \
    --app-subnet ${apps_subnet_id}

# Creates diagnostic settings to send logs and metrics to Log Analytics Workspace
az monitor diagnostic-settings create \
    --name "ToLAW" \
    --resource ${azurespringcloud_service} \
    --resource-group ${azurespringcloud_resourcegroup_name} \
    --resource-type Microsoft.AppPlatform/Spring \
    --workspace ${log_analytics_workspace_name} \
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
            "category": "Performance (Java)",
            "enabled": true,
            "retentionPolicy": {
                "enabled": false,
                "days": 0
                }
        },
        {
            "category": "Request (Java)",
            "enabled": true,
            "retentionPolicy": {
                "enabled": false,
                "days": 0
                }
        },
        {
            "category": "Error (Java)",
            "enabled": true,
            "retentionPolicy": {
                "enabled": false,
                "days": 0
                }
        },
        {
            "category": "Session (Java)",
            "enabled": true,
            "retentionPolicy": {
                "enabled": false,
                "days": 0
                }
        },
        {
            "category": "Performance (.NET)",
            "enabled": true,
            "retentionPolicy": {
                "enabled": false,
                "days": 0
                }
        },
        {
            "category": "Request (.NET)",
            "enabled": true,
            "retentionPolicy": {
                "enabled": false,
                "days": 0
                }
        },
        {
            "category": "Common",
            "enabled": true,
            "retentionPolicy": {
                "enabled": false,
                "days": 0
                }
        }
    ]'


#Gets Azure Spring Cloud apps routetable and adds route to Azure Firewall
azurespringcloud_app_resourcegroup_name=$(az spring-cloud show \
    --resource-group ${azurespringcloud_resource_group_name} \
    --name ${azurespringcloud_service} \
    --query 'properties.networkProfile.appNetworkResourceGroup' --output tsv )

azurepringcloud_app_routetable_name=$(az network route-table list \
    --resource-group ${azurespringcloud_app_resourcegroup_name} \
    --query [].name --output tsv)

az network route-table route create \
    --resource-group ${azurespringcloud_app_resourcegroup_name} \
    --route-table-name ${azurepringcloud_app_routetable_name} \
    --name default \
    --address-prefix 0.0.0.0/0 \
    --next-hop-type VirtualAppliance \
    --next-hop-ip-address ${firewall_private_ip}




#Gets Azure Spring Cloud service runtime routetable and adds route to Azure Firewall
azurespringcloud_service_resourcegroup_name=$(az spring-cloud show \
    --resource-group ${azurespringcloud_resource_group_name} \
    --name ${azurespringcloud_service} \
    --query 'properties.networkProfile.serviceRuntimeNetworkResourceGroup' --out tsv )

azurepringcloud_service_routetable_name=$(az network route-table list \
    --resource-group ${azurespringcloud_service_resourcegroup_name} \
    --query [].name --out tsv)

az network route-table route create \
    --resource-group ${azurespringcloud_service_resourcegroup_name} \
    --route-table-name ${azurepringcloud_service_routetable_name} \
    --name default \
    --address-prefix 0.0.0.0/0 \
    --next-hop-type VirtualAppliance \
    --next-hop-ip-address ${firewall_private_ip}





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

