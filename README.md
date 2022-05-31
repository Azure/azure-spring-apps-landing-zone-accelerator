# Quickstart - Azure Spring Apps Reference Architecture

## Azure Spring Apps

Azure Spring Apps is a fully managed service for Spring Boot apps that lets you focus on 
building the apps that run your business without the hassle of managing infrastructure. 
Simply deploy your JARs or code and Azure Spring Apps will automatically wire your apps with 
the Spring service runtime. Once deployed you can easily monitor application performance, 
fix errors, and rapidly improve applications.

Azure Spring Apps is jointly built, operated, and supported by Microsoft and VMware. 
You can use Azure Spring Apps for your most demanding applications and be assured 
that Microsoft and VMware are standing behind the service to ensure your success.

## Quickstart Overview

This repository contains instructions for creating an 
[Azure Spring Apps](https://docs.microsoft.com/azure/spring-cloud/spring-cloud-overview)
reference architecture that can be used for experimenting with Spring Boot 
applications in a typical enterprise landing zone design for a regulated organization. 
It uses a [hub and spoke architecture](https://docs.microsoft.com/azure/architecture/reference-architectures/hybrid-networking/hub-spoke) 
with a single spoke.  East/West traffic (traffic between resources in the hub and resources in the 
spoke) is filtered with Network Security Groups and North/South traffic (traffic between the 
Internet and resources in the hub or spoke) is routed through and mediated with an instance of 
Azure Firewall.  

![lab image](images/architecture-private.svg)

Additional features of this quickstart are:

* Azure Spring Apps is deployed using [vnet-injection](https://docs.microsoft.com/azure/spring-cloud/spring-cloud-tutorial-deploy-in-azure-virtual-network) 
to allow for mediation inbound and outbound traffic to the Azure Spring Apps Instance and deployed applications.
* The Azure Firewall instance has been configured to write its logs to a Log Analytics Workspace. 
You can leverage [these Kusto queries](https://docs.microsoft.com/azure/firewall/log-analytics-samples) 
to analyze Azure Firewall log data written to Log Analytics.
* Hub and Spoke Virtual Networks are configured to use Azure Firewall for DNS queries 
utilizing the [DNS Proxy feature](https://docs.microsoft.com/azure/firewall/dns-settings#dns-proxy) 
of Azure Firewall.
* Azure Private DNS zones for Azure Spring Apps and support services deployed with Private Endpoints
* A single Windows Server 2016 Virtual Machine the hub Virtual Network for testing access to 
applications deployed into the Azure Spring Apps instance.  This virtual machine is configured 
with the Microsoft Monitoring Agent and is integrated with the Log Analytics Workspace. This VM is 
not exposed to the internet and is only accessible via Azure Bastion (for brevity, both the VM and Azure
Bastion are not shown in the diagram).
* Log Analytics Workspace where Azure Spring Apps, Azure Firewall, and the virtual machine deliver 
logs and metrics.
* Instance of Azure Key Vault deployed with a Private Endpoint for secrets and certificates storage 
for applications deployed to Azure Spring Apps
* Instance of Azure Database for MySQL deployed with a Private Endpoint.  This can be used to deploy 
the sample app described in this document.
* Instance of Azure Bastion for connection to the Windows Server 2016 virtual machine running in the hub virtual network.

## Deployment Process

There are three methods to deploy the architecture in the diagram documented in this repo.

* [ARM Deployment](/ARM)
* [Terraform Deployment](/terraform)
* [CLI Deployment](/CLI)
* [Bicep Deployment](/Bicep)

ARM, Terraform, CLI and Bicep scripts will deploy Azure Spring Apps in a secure environment. Once the core 
infrastructure has been deployed, the Post Installation process can be followed to test sample 
applications.

## Build your solutions today!

Azure Spring Apps abstracts away the complexity of infrastructure management and Spring Apps 
middleware management, so you can focus on building your business logic and let Azure take care 
of dynamic scaling, patches, security, compliance, and high availability. With a few steps, 
you can provision Azure Spring Apps, create applications, deploy, and scale Spring Boot applications
 and start monitoring in minutes. We will continue to bring more developer-friendly and 
 enterprise-ready features to Azure Spring Apps. 

We would love to hear how you are building impactful solutions using Azure Spring Apps. 
Get started today – deploy Spring applications to Azure Spring Apps using this quickstart!

### Resources
* Learn using an [MS Learn module](https://docs.microsoft.com/learn/modules/azure-spring-cloud-workshop/)
 or [self-paced workshop](https://github.com/microsoft/azure-spring-cloud-training) on GitHub
* Learn [more](https://docs.microsoft.com/azure/spring-cloud/) about implementing solutions on Azure Spring Apps
* [Deploy](https://github.com/Azure-Samples/spring-petclinic-microservices) a distributed version of Spring Petclinic built with Spring Apps
* Migrate your [Spring Boot](https://docs.microsoft.com/azure/developer/java/migration/migrate-spring-boot-to-azure-spring-cloud), 
[Spring Apps](https://docs.microsoft.com/azure/developer/java/migration/migrate-spring-cloud-to-azure-spring-cloud) and 
[Tomcat applications](https://aka.ms/migrate-tomcat-to-azure-spring-cloud-service) to Azure Spring Apps
* Wire Spring applications to [interact with Azure services](https://docs.microsoft.com/azure/developer/java/spring-framework/).
* Use the [Azure Spring Apps extension for VS Code](https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-azurespringcloud) to quickly create, manage and deploy apps to an Azure Spring Apps instance.

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
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
