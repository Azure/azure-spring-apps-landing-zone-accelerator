# Create an Azure Spring Cloud Cluster into an existing Virtual Network

This template will create an Azure Spring Cloud cluster into an existing Virtual Network. This can be used with or without an NVA (Network Virtual Appliance) or Azure FIrewall for restricting egress traffic. This will also create a [workspace-based](https://docs.microsoft.com/en-us/azure/azure-monitor/app/create-workspace-resource) Azure Application Insights resource and deploy into an existing Log Analytics Workspace. The Azure Spring cloud Diagnostics settings will also be configured to use the Log Analytics Workspace.

## Prerequisites

* 2 dedicated subnets for the Azure Spring Cloud Cluster. One for the service runtime and another for the Spring Boot micro-service applications. see [here](https://docs.microsoft.com/en-us/azure/spring-cloud/how-to-deploy-in-azure-virtual-network#virtual-network-requirements) for subnet and virtual network requirements.
* An existing Log Analytics workspace for Azure Spring Cloud [diagnostics settings](https://docs.microsoft.com/en-us/azure/spring-cloud/diagnostic-services) as well as a workspace-based [Application Insights](https://docs.microsoft.com/en-us/azure/spring-cloud/how-to-distributed-tracing) resource.
* You must plan the 3 internal CIDR ranges (at least /16 each) used for the Azure Spring Cloud cluster. These will not be directly routable and will be used only internally by the Azure Spring Cloud Cluster. Clusters may not use 169.254.0.0/16, 172.30.0.0/16, 172.31.0.0/16, or 192.0.2.0/24 for the internal Spring Cloud CIDR ranges, or any IP ranges included within the cluster virtual network address range.
* Grant service permission to the virtual network. The Azure Spring Cloud Resource Provider requires Owner permission to your virtual network in order to grant a dedicated and dynamic service principal on the virtual network for further deployment and maintenance. See [here](https://docs.microsoft.com/en-us/azure/spring-cloud/how-to-deploy-in-azure-virtual-network#grant-service-permission-to-the-virtual-network) for instructions and more information.
* If using Azure Firewall or an NVA you will need the following:
  * Network and FQDN rules. see [requirements](https://docs.microsoft.com/en-us/azure/spring-cloud/how-to-deploy-in-azure-virtual-network#virtual-network-requirements).
  * A unique UDR ([User Defined Route](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview)) applied to each of the service runtime and Spring Boot micro-service application subnets. The UDR should be configured with a route for **0.0.0.0/0** with a destination of your NVA before deploying the spring cloud cluster. See [here](https://docs.microsoft.com/en-us/azure/spring-cloud/how-to-deploy-in-azure-virtual-network#bring-your-own-route-table) for more information.

Below are the parameters which can be user configured in the parameters file including:

- **springCloudInstanceName:** Enter the name of the Azure Spring Cloud resource.
- **appInsightsName:** Enter the name of the Application Insights instance for Azure Spring Cloud.
- **laWorkspaceResourceId:** Enter the resource ID of the existing Log Analytics workspace. e.g "/subscriptions/[your sub]/resourcegroups/[your log analytics rg]/providers/Microsoft.OperationalInsights/workspaces/[your log analytics workspace name]"
- **springCloudAppSubnetID:** Enter the resourceID of the Azure Spring Cloud App Subnet.
- **springCloudRuntimeSubnetID:** Enter the resourceID of the Azure Spring Cloud Runtime Subnet.
- **springCloudServiceCidrs:** Enter a comma-separated list of IP address ranges (3 in total) in CIDR format. The IP ranges are reserved to host underlying Azure Spring Cloud infrastructure, which should be 3 at least /16 unused IP ranges, must not overlap with any routable subnet IP ranges used within the network.
- **tags:** Enter any custom tags.

## Deployment

```bash
    az deployment group create --resource-group ${RESOURCE_GROUP} \
    --name initial \
    --template-file brownfield-deployment/azuredeploy.bicep \
    --parameters springCloudInstanceName=<> appInsightsName=<> laWorkspaceResourceId=<> springCloudAppSubnetID=<> springCloudRuntimeSubnetID=<> springCloudServiceCidrs=<>
```
