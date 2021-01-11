#!/bin/bash

#parameters
randomstring=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 7 | head -n 1)
location='eastus' #location of Azure Spring Cloud Virtual Network
hub_vnet_name='hub-vnet' #Hub Virtual Network Name
hub_resource_group_name='hub-rg' #Hub Virtual Network Resource Group name
hub_vnet_address_prefixes='10.9.0.0/16' #Hub Virtual Network Address Prefixes
firewal_subnet_prefix='10.9.0.0/24' #Address prefix of FW subnet 
centralized_services_subnet_name='centralized-services-subnet' #Hub Vnet centralized services subnet
centralized_services_subnet_prefix='10.9.1.0/24' #Hub VNet centralized services subnet prefix
gateway_subnet_prefix='10.9.2.0/24' #Hub Vnet Virtual network gateway subnet name
bastion_subnet_prefix='10.9.4.0/24' #Hub VNet bastion prefix name
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
azure_spring_cloud_data_subnet_name='data-subnet' #azure Spring Cloud data subnet name
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

echo "Enter VM admin password: "
read vmpassword
vm_password=$vmpassword

echo "create hub vnet rg"

az group create --location ${location} --name ${hub_resource_group_name}

echo create NSG for jump box VM
az network nsg create \
    --resource-group ${hub_resource_group_name} \
    --name ${hub_vnet_jumpbox_nsg_name}
echo Jumpbox NSG has been created

echo create hub vnet

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
    --address-prefix ${bastion_subnet_prefix}

echo all subnets and vnet created

echo create bastion in hub vnet
az network public-ip create --resource-group ${hub_resource_group_name} --name azbastion-pip --sku Standard --location ${location}

az network bastion create --resource-group ${hub_resource_group_name} --name azbastion --public-ip-address azbastion-pip --vnet-name ${hub_vnet_name} --location ${location}
echo bastion creation finished


echo create Jumpbox VM
az vm create \
    --resource-group ${hub_resource_group_name} \
    --name jumpbox \
    --image win2019datacenter \
    --admin-username azureuser \
    --admin-password $vm_password \
    --vnet-name ${hub_vnet_name} \
    --subnet ${centralized_services_subnet_name} \
    --public-ip-address "" \
    --nsg ""

echo create FW
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

echo create FW network rules
az network firewall network-rule create \
    --collection-name SpringCloudAccess \
    --destination-ports 123 \
    --firewall-name ${firewall_name} \
    --name NtpQuery \
    --protocols UDP \
    --resource-group ${hub_resource_group_name} \
    --action Allow \
    --destination-addresses "*" \
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
    --name UbuntuLibraries \
    --description "Required CRL Rules" \
    --protocols https=443 \
    --resource-group ${hub_resource_group_name} \
    --source-addresses ${azurespringcloud_app_subnet_prefix} ${azurespringcloud_service_runtime_subnet_prefix} \
    --target-fqdns  "crl.microsoft.com" "mscrl.microsoft.com" "crl3.digicert.com" "ocsp.digicert.com" \
    --priority 101 \
    --action allow

echo Finished creating FW rules


az network vnet create \
    --name ${azurespringcloud_vnet_name} \
    --resource-group ${hub_resource_group_name} \
    --location ${location} \
    --address-prefixes ${azurespringcloud_vnet_address_prefixes} \
    --dns-servers ${firewall_private_ip}

#Create Azure Spring Cloud apps subnet
az network vnet subnet create  \
    --name ${azurespringcloud_service_runtime_subnet_name} \
    --resource-group ${hub_resource_group_name} \
    --vnet-name ${azurespringcloud_vnet_name} \
    --address-prefix ${azurespringcloud_service_runtime_subnet_prefix}

#Create Azure Spring Cloud App Subnet
az network vnet subnet create \
    --name ${azurespringcloud_app_subnet_name} \
    --resource-group ${hub_resource_group_name} \
    --vnet-name ${azurespringcloud_vnet_name} \
    --address-prefix ${azurespringcloud_app_subnet_prefix}


az network vnet subnet create \
    --name ${azure_spring_cloud_data_subnet_name} \
    --resource-group ${hub_resource_group_name} \
    --vnet-name ${azurespringcloud_vnet_name} \
    --address-prefix ${azurespringcloud_data_subnet_prefix}

az network vnet subnet create \
    --name ${azure_spring_cloud_support_subnet_name} \
    --resource-group ${hub_resource_group_name} \
    --vnet-name ${azurespringcloud_vnet_name} \
    --address-prefix ${azurespringcloud_support_subnet_prefix} \
    --disable-private-endpoint-network-policies true
echo finished creating azure spring cloud subnets and vnet

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

echo assign owner to Azure Spring Cloud spoke

az role assignment create \
    --role "Owner" \
    --scope ${azurespringcloud_vnet_id} \
    --assignee e8de9221-a19c-4c81-b814-fd37c6caf9d2

echo owner role is added

echo create peering from Spring cloud vnet to hub vnet

az network vnet peering create \
    --name azurespringcloud_vnet_to_hub_vnet \
    --resource-group ${hub_resource_group_name} \
    --vnet-name ${azurespringcloud_vnet_name} \
    --remote-vnet ${hub_vnet_name} \
    --allow-vnet-access

echo finished peering ASC spoke to hub Vnet

echo create peering from hub vnet to Spring cloud vnet

#Peer Hub Vnet to Azure Spring Cloud Spoke VNet
az network vnet peering create \
    --name hub_vnet_to_azurespringcloud_vnet \
    --resource-group ${hub_resource_group_name} \
    --vnet-name ${hub_vnet_name} \
    --remote-vnet ${azurespringcloud_vnet_name} \
    --allow-vnet-access

echo finished peering of hub to ASC spoke

echo create Azure Spring Cloud Resource group


echo creating spring cloud AKV
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


#Link Private DNS Zone to Azure Spring Cloud VNet
az network private-dns link vnet create \
    --resource-group ${hub_resource_group_name} \
    --name link-to-${azurespringcloud_vnet_name} \
    --zone-name privatelink.vaultcore.azure.net \
    --virtual-network ${azurespringcloud_vnet_id} \
    --registration-enabled false

#Link Private DNS Zone to Hub VNet
az network private-dns link vnet create \
    --resource-group ${hub_resource_group_name} \
    --name link-to-${hub_vnet_name} \
    --zone-name privatelink.vaultcore.azure.net \
    --virtual-network ${hub_vnet_id}\
    --registration-enabled false

echo finished creating azure spring cloud akv

echo Creating mySQL Db
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
    --group-id vault \
    --connection-name "mysql-private-link-connection"

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
echo MySql DB, Private endpoint and Private DNS Zone complete

echo Getting app subnet id

apps_subnet_id=$(az network vnet subnet show \
    --resource-group ${hub_resource_group_name} \
    --vnet-name ${azurespringcloud_vnet_name} \
    --name ${azurespringcloud_app_subnet_name} \
    --query id --output tsv)

echo got app subnet id.  Id is $apps_subnet_id

echo getting service runtime subnet id

service_runtime_subnet_id=$(az network vnet subnet show \
    --resource-group ${hub_resource_group_name} \
    --vnet-name ${azurespringcloud_vnet_name} \
    --name ${azurespringcloud_service_runtime_subnet_name} \
    --query id --output tsv)

echo id is $service_runtime_subnet_id

az group create --location ${location} --name ${azurespringcloud_resource_group_name}

echo creating spring cloud

az spring-cloud create \
    --name ${azurespringcloud_service} \
    --resource-group ${azurespringcloud_resource_group_name} \
    --location ${location} \
    --app-network-resource-group ${azurespringcloud_app_resource_group_name} \
    --service-runtime-network-resource-group ${azurespringcloud_service_runtime_resource_group_name} \
    --vnet ${azurespringcloud_vnet_id} \
    --service-runtime-subnet ${service_runtime_subnet_id} \
    --app-subnet ${apps_subnet_id}

echo finished creating spring cloud

echo starting routetable

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

echo finished apps route table

echo starting route table

#Add UDR in service subnet route table for NVA
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

echo finished service runtime route table

echo creating private dns zone

#Create Private DNS Zone for Azure Spring Cloud
az network private-dns zone create \
    --resource-group ${hub_resource_group_name} \
    --name private.azuremicroservices.io

echo creating link to Azure Spring Cloud Vnet

#Link Private DNS Zone to Azure Spring Cloud VNet
az network private-dns link vnet create \
    --resource-group ${hub_resource_group_name} \
    --name link-to-${azurespringcloud_vnet_name} \
    --zone-name private.azuremicroservices.io \
    --virtual-network ${azurespringcloud_vnet_id} \
    --registration-enabled false

echo creating link to Hub Vnet

#Link Private DNS Zone to Hub VNet
az network private-dns link vnet create \
    --resource-group ${hub_resource_group_name} \
    --name link-to-${hub_vnet_name} \
    --zone-name private.azuremicroservices.io \
    --virtual-network ${hub_vnet_id}\
    --registration-enabled false

echo getting ilb private ip

#Get Azure Spring Cloud service runtime subnet internal load balancer private IP address
azurespringcloud_internal_lb_private_ip=$(az network lb show --name kubernetes-internal \
    --resource-group ${azurespringcloud_service_runtime_resource_group_name} \
    --query frontendIpConfigurations[*].privateIpAddress --out tsv )
#Add A record in Private DNS Zone for internal Azure Spring Cloud load balancer

echo starting to add A record for ILB load balancer
az network private-dns record-set a add-record \
    --resource-group ${hub_resource_group_name} \
    --zone-name private.azuremicroservices.io \
    --record-set-name '*' \
    --ipv4-address ${azurespringcloud_internal_lb_private_ip}

echo finished adding A record
