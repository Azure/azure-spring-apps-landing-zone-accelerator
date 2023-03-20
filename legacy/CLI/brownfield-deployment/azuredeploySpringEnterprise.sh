#!/bin/bash

echo "Enter Azure Subscription ID: "
read subscription
subscription=$subscription

echo "Enter Azure region for resource deployment: "
read region
location=$region

echo "Enter Azure Spring  Resource Group Name: "
read azurespringrg
azurespring_resource_group_name=$azurespringrg

echo "Enter Azure Spring VNet Resource Group Name: "
read azurespringvnetrg
azurespring_vnet_resource_group_name=$azurespringvnetrg

echo "Enter Azure Spring Spoke VNet : "
read azurespringappspokevnet
azurespringappspokevnet=$azurespringappspokevnet

echo "Enter Azure Spring App SubNet : "
read azurespringappsubnet
azurespring_app_subnet_name='/subscriptions/'$subscription'/resourcegroups/'$azurespring_vnet_resource_group_name'/providers/Microsoft.Network/virtualNetworks/'$azurespringappspokevnet'/subnets/'$azurespringappsubnet

echo "Enter Azure Spring Service SubNet : "
read azurespringservicesubnet
azurespring_service_subnet_name='/subscriptions/'$subscription'/resourcegroups/'$azurespring_vnet_resource_group_name'/providers/Microsoft.Network/virtualNetworks/'$azurespringappspokevnet'/subnets/'$azurespringservicesubnet

echo "Enter Azure Log Analytics Workspace Resource Group Name: "
read loganalyticsrg
loganalyticsrg=$loganalyticsrg

echo "Enter Log Analytics Workspace Resource ID: "
read workspace
workspaceID='/subscriptions/'$subscription'/resourcegroups/'$loganalyticsrg'/providers/microsoft.operationalinsights/workspaces/'$workspace

echo "Enter Reserved CIDR Ranges for Azure Spring: "
read reservedcidrrange
reservedcidrrange=$reservedcidrrange

echo "Enter key=value pair used for tagging Azure Resources (space separated for multiple tags): "
read tag
tags=$tag

randomstring=$(LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | fold -w 13 | head -n 1)
azurespring_service='spring-'$randomstring #Name of unique Spring resource
azurespring_appinsights=$azurespring_service
azurespring_resourceid='/subscriptions/'$subscription'/resourceGroups/'$azurespring_resource_group_name'/providers/Microsoft.AppPlatform/Spring/'$azurespring_service

# Create Application Insights
az monitor app-insights component create \
    --app ${azurespring_service} \
    --location ${location} \
    --kind web \
    -g ${azurespringrg} \
    --application-type web \
    --workspace ${workspaceID}

az spring create \
    -n ${azurespring_service} \
    -g ${azurespringrg} \
    -l ${location} \
    --sku Enterprise \
    --build-pool-size S1 \
    --enable-application-configuration-service \
    --enable-service-registry \
    --enable-gateway \
    --enable-api-portal \
    --api-portal-instance-count 2 \
    --enable-java-agent true \
    --app-insights ${azurespring_service} \
    --app-subnet ${azurespring_app_subnet_name} \
    --service-runtime-subnet ${azurespring_service_subnet_name} \
    --reserved-cidr-range ${reservedcidrrange} \
    --tags ${tags}

# Update diagnostic setting for Azure Spring instance
az monitor diagnostic-settings create  \
   --name monitoring \
   --resource ${azurespring_resourceid} \
   --logs    '[{"category": "ApplicationConsole","enabled": true}]' \
   --workspace  ${workspaceID}