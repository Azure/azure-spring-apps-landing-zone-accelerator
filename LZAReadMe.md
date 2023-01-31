# Azure Spring Apps Landing Zone Accelerator

Azure Landing Zone Accelerators are architectural guidance, reference architecture, reference implementations and automation packaged to deploy workload platforms on Azure at Scale and aligned with industry proven practices.

Azure Spring apps Landing Zone Accelerator represents the strategic design path and target technical state for an Azure Spring Apps Service deployment. 

This repository provides packaged guidance for customer scenarios, reference architecture, reference implementation, tooling, design area guidance, sample spring apps deployed after provisioning the infrastructure using the accelerator. The architectural approach can be used as design guidance for greenfield implementation and as an assessment for brownfield customers already using Spring boot apps. 

## Enterprise-Scale Architecture

The enterprise architecture is broken down into six different design areas, where you can find the links to each at:
| Design Area|Considerations and Recommendations|
|:--------------:|:--------------:|
| Identity and Access Management|[Design Considerations and Recommendations](/docs/Design-Areas/LZA-ASA-IAM.md)
| Network Topology and Connectivity|[Design Considerations and Recommendations](/docs/Design-Areas/LZA-ASA-Network-Topology.md)
| Management and Monitoring|[Design Considerations and Recommendations](/docs/Design-Areas/LZA-ASA-Mangement%20And%20Operations.md)
| Security, Governance, and Compliance|[Design Considerations and Recommendations](/docs/Design-Areas/LZA-ASA-Security.md)

## Enterprise-Scale Reference Implementation


This repository contains instructions for creating an 
[Azure Spring Apps](https://docs.microsoft.com/azure/spring-cloud/spring-cloud-overview)
reference architecture that can be used for deploying Spring Boot 
applications in a typical enterprise landing zone design. 
It uses a [hub and spoke architecture](https://docs.microsoft.com/azure/architecture/reference-architectures/hybrid-networking/hub-spoke) 
with a single spoke.  East/West traffic (traffic between resources in the hub and resources in the 
spoke) is filtered with Network Security Groups and North/South traffic (traffic between the 
Internet and resources in the hub or spoke) is routed through and mediated with an instance of 
Azure Firewall. 

![lab image](images/architecture-private.svg)

* Azure Spring Apps is deployed using [vnet-injection](https://docs.microsoft.com/azure/spring-cloud/spring-cloud-tutorial-deploy-in-azure-virtual-network) 
to allow for mediation inbound and outbound traffic to the Azure Spring Apps Instance and deployed applications.
* The Azure Firewall instance has been configured to write its logs to a Log Analytics Workspace. 
You can leverage [these Kusto queries](https://docs.microsoft.com/azure/firewall/log-analytics-samples) 
to analyze Azure Firewall log data written to Log Analytics.
* Hub and Spoke Virtual Networks are configured to use Azure Firewall for DNS queries 
utilizing the [DNS Proxy feature](https://docs.microsoft.com/azure/firewall/dns-settings#dns-proxy) 
of Azure Firewall.
* Azure Private DNS zones for Azure Spring Apps and support services deployed with Private Endpoints
* A single Windows Server 2022 Virtual Machine the hub Virtual Network for testing access to 
applications deployed into the Azure Spring Apps instance.  This virtual machine is configured 
with the Microsoft Monitoring Agent and is integrated with the Log Analytics Workspace. This VM is 
not exposed to the internet and is only accessible via Azure Bastion (for brevity, both the VM and Azure
Bastion are not shown in the diagram).
* Log Analytics Workspace where Azure Spring Apps, Azure Firewall, and the virtual machine deliver 
logs and metrics.
* Instance of Azure Key Vault deployed with a Private Endpoint for secrets and certificates storage 
for applications deployed to Azure Spring Apps
* Instance of Azure Bastion for connection to the Windows Server 2022 virtual machine running in the hub virtual network.

For Azure Spring Apps Standard SKU:
* Instance of Azure Database for MySQL flexible server deployed with VNET Integration.  This can be used to deploy the PetClinic sample app described in this document.

For Azure Spring Apps Enterprise SKU:
* Instance of Azure Database for PostgreSQL flexible server deployed with VNET Integration and Azure Cache for Redis with Private endpoint.  

Deployment Details:
| Deployment Methodology | GitHub Actions
|--------------|--------------|
|[Terraform]|Coming soon|
|[Bicep]|Coming soon|

Cost estimation:

---

## Other Considerations

1. Please leverage issues if you have any feedback or request on how we can improve on this repository.

---

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
