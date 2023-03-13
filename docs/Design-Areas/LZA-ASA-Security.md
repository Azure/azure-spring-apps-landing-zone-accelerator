<!-- Landing Zone Accelerator - Azure Spring App -Security.MD v2 -->

### Security considerations for Azure Spring Apps Landing Zone Accelerator

This ReadMe File provides design considerations and recommendations for Security when you use Azure Spring Apps landing zone accelerator.  It walks through aspects of Azure Spring Apps (ASA) security governance to think about before implementing any solution.

Most of this content is technology-agnostic, because implementation varies among customers. The ReadMe File focuses on how to implement solutions using Azure and open-source software. The decisions made when you create an enterprise-scale landing zone can partially predefine your governance. It's important to understand governance principles because of the effect of the decisions made.

Azure Spring Apps is the new name for the Azure Spring Cloud service. Security controls are built into Azure Spring Apps Service.

A security control is a quality or feature of an Azure service that contributes to the service's ability to prevent, detect, and respond to security vulnerabilities. For each control, we use Yes or No to indicate whether it is currently in place for the service. We use N/A for a control that is not applicable to the service.

### Azure Spring Apps Landing Zone - Topology

![Architectural diagram for the secure baseline scenario.](Scenarios/ASA-Secure-Baseline/media/asa-eslz-securebaseline.jpg)

### Azure Spring Apps Landing Zone - Azure Components

| Component | Overview | Location |
|-------------|---------------|---------------|
| Azure Firewall |<p>Azure Firewall is a cloud-native and intelligent network firewall security service that provides the best of breed threat protection for your cloud workloads running in Azure. It's a fully stateful, firewall as a service with built-in high availability and unrestricted cloud scalability. It provides both east-west and north-south traffic inspection. To learn what's east-west and north-south traffic, see <a href="/en-us/azure/architecture/framework/security/design-network-flow#east-west-and-north-south-traffic" data-linktype="absolute-path">East-west and north-south traffic</a>. Azure Firewall is offered in three SKUs: Standard, Premium, and Basic.</p>|Hub|
| Bastion |<p>Azure Bastion is a service you deploy that lets you connect to a virtual machine using your browser and the Azure portal, or via the native SSH or RDP client already installed on your local computer. The Azure Bastion service is a fully platform-managed PaaS service that you provision inside your virtual network. It provides secure and seamless RDP/SSH connectivity to your virtual machines directly from the Azure portal over TLS. When you connect via Azure Bastion, your virtual machines don't need a public IP address, agent, or special client software. Bastion provides secure RDP and SSH connectivity to all of the VMs in the virtual network in which it is provisioned. Using Azure Bastion protects your virtual machines from exposing RDP/SSH ports to the outside world, while still providing secure access using RDP/SSH.</p>| Hub |
| V-Net Gateway |<p>To connect your Azure virtual network and your on-premises network using ExpressRoute, you must first create a virtual network gateway. A virtual network gateway serves two purposes: exchange IP routes between the networks and route network traffic. <p>When you create a virtual network gateway, you need to specify several settings. One of the required settings, <code>-GatewayType</code>, specifies whether the gateway is used for ExpressRoute, or VPN traffic. The two gateway types are: Vpn - To send encrypted traffic across the public Internet, you use the gateway type 'Vpn'. This type of gateway is also referred to as a VPN gateway. Site-to-Site, Point-to-Site, and VNet-to-VNet connections all use a VPN gateway. ExpressRoute - To send network traffic on a private connection, you use the gateway type 'ExpressRoute'. This type of gateway is also referred to as an ExpressRoute gateway and is used when configuring ExpressRoute.</p>| Hub |
| Appication Gateway |<p>Azure Application Gateway is a web traffic load balancer that enables you to manage traffic to your web applications. Traditional load balancers operate at the transport layer (OSI layer 4 - TCP and UDP) and route traffic based on source IP address and port, to a destination IP address and port. Application Gateway can make routing decisions based on additional attributes of an HTTP request, for example URI path or host headers. For example, you can route traffic based on the incoming URL. So if <code>/images</code> is in the incoming URL, you can route traffic to a specific set of servers (known as a pool) configured for images. If <code>/video</code> is in the URL, that traffic is routed to another pool that's optimized for videos.</p>| Hub or Spoke (depending on the clients needs and design requirements)|
| Management Jumpbox |<p>The most simple solution is to host a jumpbox on the virtual network of the data management landing zone or data landing zone to connect to the data services through private endpoints. A jumpbox is an Azure virtual machine (VM) that's running Linux or Windows and to which users can connect via the Remote Desktop Protocol (RDP) or Secure Shell (SSH). Previously, jumpbox VMs had to be hosted with public IPs to enable RDP and SSH sessions from the public internet. </p>| Spoke |
| MySql or PostgreSql DB |<p>Deliver high availability and elastic scaling to open-source mobile and web apps with a managed community MySQL database service, or migrate MySQL workloads to the cloud. or Build scalable, secure, and fully managed enterprise-ready apps on open-source PostgreSQL, scale out single-node PostgreSQL with high performance, or migrate PostgreSQL and Oracle workloads to the cloud. </p>| Spoke |
| Azure Spring Apps Instance|<p>Azure Spring Apps makes it easy to deploy Spring Boot applications to Azure without any code changes. The service manages the infrastructure of Spring applications so developers can focus on their code. Azure Spring Apps provides lifecycle management using comprehensive monitoring and diagnostics, configuration management, service discovery, CI/CD integration, blue-green deployments, and more. Azure Spring Apps is a fully managed service for Spring Boot apps that lets you focus on building and running apps without the hassle of managing infrastructure. Simply deploy your JARs or code for your Spring Boot app or Zip for your Steeltoe app, and Azure Spring Apps will automatically wire your apps with Spring service runtime and built-in app lifecycle. Monitoring is simple. After deployment you can monitor app performance, fix errors, and rapidly improve applications.| Spoke |
| Azure Private Endpoint (Private Link) |<p>A private endpoint is a network interface that uses a private IP address from your virtual network. This network interface connects you privately and securely to a service that's powered by Azure Private Link. By enabling a private endpoint, you're bringing the service into your virtual network. The service could be an Azure service such as: Azure Storage, Azure Cosmos DB, Azure Key Vault, etc..Your own service, using <a href="private-link-service-overview" data-linktype="relative-path">Private Link service</a>. </p>| Spoke |
|-------------|---------------|---------------|
------------

### Design Considerations
#### 1. Azure Security Baseline for Azure Spring Apps Service
This security baseline applies guidance from the [Azure Security Benchmark version 2.0](https://learn.microsoft.com/en-us/security/benchmark/azure/overview-v2) to Azure Spring App Service.  The Azure Security Benchmark provides recommendations on how you can secure your cloud solutions on Azure. The content is grouped by the security controls defined by the Azure Security Benchmark and the related guidance applicable to Azure Spring App Service.

You can monitor this security baseline and its recommendations using Microsoft Defender for Cloud. Azure Policy definitions will be listed in the Regulatory Compliance section of the Microsoft Defender for Cloud dashboard.

When a section has relevant Azure Policy Definitions, they are listed in this baseline to help you measure compliance to the Azure Security Benchmark controls and recommendations. Some recommendations may require a paid Microsoft Defender plan to enable certain security scenarios.

Controls not applicable to Azure Spring App Service, and those for which the global guidance is recommended verbatim, have been excluded. To see how Azure Spring App Service completely maps to the Azure Security Benchmark, see the full [Azure Spring App Service security baseline mapping file](https://github.com/MicrosoftDocs/SecurityBenchmarks/blob/master/Azure%20Offer%20Security%20Baselines/2.0/azure-spring-cloud-service-security-baseline-v2.0.xlsx).

#### 2. Data Protection Security Controls
| Security Control | Yes/No | Notes | Documentation |
|-------------|---------------|---------------|---------------|
|Server-side encryption at rest: | Yes | User uploaded source and artifacts, config server settings, app settings, and data in persistent storage are stored in Azure | [Azure Storage encryption for data at REST](https://learn.microsoft.com/en-us/azure/storage/common/storage-service-encryption)|
|Microsoft-Managed Keys| Yes |Storage, which automatically encrypts the content at rest. Config server cache, runtime binaries built from uploaded source, and application logs during the application lifetime are saved to Azure managed disk, which automatically encrypts the content at rest. Container images built from user uploaded source are saved in Azure Container Registry, which automatically encrypts the image content at rest.|[Server-side encryption of Azure managed disks](https://learn.microsoft.com/en-us/azure/virtual-machines/disk-encryption)   [Container image storage in Azure Container Registry](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-storage)|
|Encryption in transient| Yes |User app public endpoints use HTTPS for inbound traffic by default.|---------------|
|API calls encrypted| Yes |Management calls to configure Azure Spring Apps service occur via Azure Resource Manager calls over HTTPS.|[Azure Resource Manager](https://learn.microsoft.com/en-us/azure/azure-resource-manager/)|
|Customer Lockbox| Yes |Provide Microsoft with access to relevant customer data during support scenarios.|[Customer Lockbox for Microsoft Azure](https://learn.microsoft.com/en-us/azure/security/fundamentals/customer-lockbox-overview)|


#### 3. Network Access Security Controls
| Security Control | Yes/No | Notes | Documentation |
|-------------|---------------|---------------|---------------|
|Service Tag| Yes |Use Azure Spring App service tag to define outbound network access controls on [network security groups](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview#security-rules) or [Azure Firewall](https://learn.microsoft.com/en-us/azure/firewall/service-tags), to allow traffic to applications in Azure Spring Apps.|[Service tags](https://learn.microsoft.com/en-us/azure/virtual-network/service-tags-overview)|


#### 4. Micrsoft Defender for Cloud Monitoring
The [Azure Security Benchmark](https://learn.microsoft.com/en-us/azure/governance/policy/samples/azure-security-benchmark) is the default policy initiative for Microsoft Defender for Cloud and is the foundation for [Microsoft Defender for Cloud's recommendations](https://learn.microsoft.com/en-us/azure/security-center/security-center-recommendations). The Azure Policy definitions related to this control are enabled automatically by Microsoft Defender for Cloud. Alerts related to this control may require an [Microsoft Defender](https://learn.microsoft.com/en-us/azure/security-center/azure-defender) plan for the related services.


#### 5. Azure Policy Built-in Definitions - Microsoft.AppPlatform
| Name| Description | Effect(s) | Version |
|-------------|---------------|---------------|---------------|
|[Azure Spring App should use network injection](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2Faf35e2a4-ef96-44e7-a9ae-853dd97032c4)|Azure Spring App instances should use virtual network injection for the following purposes: 1. Isolate Azure Spring App from Internet. 2. Enable Azure Spring App to interact with systems in either on premises data centers or Azure service in other virtual networks. 3. Empower customers to control inbound and outbound network communications for Azure Spring App.|Audit, Disabled, Deny| 1.0.0|


#### 6. Secure Internet Communications
The TLS/SSL protocol establishes identity and trust, and encrypts communications of all types. TLS/SSL makes secure communications possible, particularly web traffic carrying commerce and customer data.

You can use any type of TLS/SSL certificate. For example, you can use certificates issued by a certificate authority, extended validation certificates, wildcard certificates with support for any number of subdomains, or self-signed certificates for dev and testing environments.


#### 7. Load Certificates Securitty with Zero Trust
Zero Trust is based on the principle of "never trust, always verify, and credential-free". Zero Trust helps to secure all communications by eliminating unknown and unmanaged certificates. Zero Trust involves trusting only certificates that are shared by verifying identity prior to granting access to those certificates. For more information, see the [Zero Trust Guidance Center](https://learn.microsoft.com/en-us/security/zero-trust/).

To securely load certificates from [Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/), Spring Boot apps use [managed identities](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview) and [Azure role-based access control (RBAC)](https://learn.microsoft.com/en-us/azure/role-based-access-control/). Azure Spring Apps uses a provider service principal and Azure role-based access control. This secure loading is powered using the Azure Key Vault Java Cryptography Architecture (JCA) Provider. For more information, see [Azure Key Vault JCA client library for Java](https://github.com/Azure/azure-sdk-for-java/tree/main/sdk/keyvault/azure-security-keyvault-jca).

If your Spring code, Java code, or open-source libraries, such as OpenSSL, rely on the JVM default JCA chain to implicitly load certificates into the JVM's trust store, then you can import your TLS/SSL certificates from Key Vault into Azure Spring Apps and use those certificates within the app. For more information, see [Use TLS/SSL certificates in your application in Azure Spring Apps](https://learn.microsoft.com/en-us/azure/spring-apps/how-to-use-tls-certificate).

#### 8. Upload well known public TLS/SSL certificates for Backend Systems
For an app to communicate to backend services in the cloud or in on-premises systems, it may require the use of public TLS/SSL certificates to secure communication. You can upload those TLS/SSL certificates for securing outbound communications. For more information, see [Use TLS/SSL certificates in your application in Azure Spring Apps](https://learn.microsoft.com/en-us/azure/spring-apps/how-to-use-tls-certificate).

#### 9. Automate provisioning and configuration for Securing Communications
Using an ARM Template, Bicep, or Terraform, you can automate the provisioning and configuration of all the Azure resources mentioned above for securing communications.

------------

### Design Recommendations
#### 1. Azure Policy Regulatory Compliance Controls for Azure Spring Apps
Azure Spring Apps is the new name for the Azure Spring App service. Although the service has a new name, you'll see the old name in some places for a while as we work to update assets such as screenshots, videos, and diagrams.

[Regulatory Compliance in Azure Policy](https://learn.microsoft.com/en-us/azure/governance/policy/concepts/regulatory-compliance) provides Microsoft created and managed initiative definitions, known as built-ins, for the compliance domains and security controls related to different compliance standards. This page lists the compliance domains and security controls for Azure Spring Apps. You can assign the built-ins for a security control individually to help make your Azure resources compliant with the specific standard.

The title of each built-in policy definition links to the policy definition in the Azure portal. Use the link in the Policy Version column to view the source on the [Azure Policy GitHub repo](https://github.com/Azure/azure-policy).

Each control is associated with one or more [Azure Policy definitions](https://learn.microsoft.com/en-us/azure/governance/policy/overview). These policies might help you [assess compliance](https://learn.microsoft.com/en-us/azure/governance/policy/how-to/get-compliance-data) with the control. However, there often isn't a one-to-one or complete match between a control and one or more policies. As such, Compliant in Azure Policy refers only to the policies themselves. This doesn't ensure that you're fully compliant with all requirements of a control. In addition, the compliance standard includes controls that aren't addressed by any Azure Policy definitions at this time. Therefore, compliance in Azure Policy is only a partial view of your overall compliance status. The associations between controls and Azure Policy Regulatory Compliance definitions for these compliance standards can change over time.

#### 2. Azure Security Benchmark
The [Azure Security Benchmark](https://learn.microsoft.com/en-us/security/benchmark/azure/introduction) provides recommendations on how you can secure your cloud solutions on Azure. To see how this service completely maps to the Azure Security Benchmark, see the [Azure Security Benchmark mapping files](https://github.com/MicrosoftDocs/SecurityBenchmarks/tree/master/Azure Offer Security Baselines).

To review how the available Azure Policy built-ins for all Azure services map to this compliance standard, see [Azure Policy Regulatory Compliance - Azure Security Benchmark](https://learn.microsoft.com/en-us/azure/governance/policy/samples/azure-security-benchmark).

| Domain | Control ID | Control Title | Policy | Policy Version |
|---------------|---------------|---------------|---------------|---------------|
|Network Security|NS-2|Secure cloud services with network controls|[Azure Spring App should use network injection](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2Faf35e2a4-ef96-44e7-a9ae-853dd97032c4)|1.1.0|


#### 3. FedRAMP High
To review how the available Azure Policy built-ins for all Azure services map to this compliance standard, see [Azure Policy Regulatory Compliance - FedRAMP High](https://learn.microsoft.com/en-us/azure/governance/policy/samples/fedramp-high). For more information about this compliance standard, see [FedRAMP High](https://www.fedramp.gov/).

| Domain | Control ID | Control Title | Policy | Policy Version |
|---------------|---------------|---------------|---------------|---------------|
|Access Control|AC-17|Remote Access|[Azure Spring App should use network injection](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2Faf35e2a4-ef96-44e7-a9ae-853dd97032c4)|1.1.0|
|Access Control|AC-17 (1)|Automated Monitoring / Control|[Azure Spring App should use network injection](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2Faf35e2a4-ef96-44e7-a9ae-853dd97032c4)|1.1.0|


#### 4. FedRAMP Moderate
To review how the available Azure Policy built-ins for all Azure services map to this compliance standard, see [Azure Policy Regulatory Compliance - FedRAMP Moderate](https://learn.microsoft.com/en-us/azure/governance/policy/samples/fedramp-moderate). For more information about this compliance standard, see [FedRAMP Moderate](https://www.fedramp.gov/.

| Domain | Control ID | Control Title | Policy | Policy Version |
|---------------|---------------|---------------|---------------|---------------|
|Access Control|AC-17|Remote Access|[Azure Spring App should use network injection](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2Faf35e2a4-ef96-44e7-a9ae-853dd97032c4)|1.1.0|
|Access Control|AC-17 (1)|Automated Monitoring / Control|[Azure Spring App should use network injection](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2Faf35e2a4-ef96-44e7-a9ae-853dd97032c4)|1.1.0|

#### 5. New Zealand ISM Restricted
To review how the available Azure Policy built-ins for all Azure services map to this compliance standard, see [Azure Policy Regulatory Compliance - New Zealand ISM Restricted](https://learn.microsoft.com/en-us/azure/governance/policy/samples/new-zealand-ism). For more information about this compliance standard, see [New Zealand ISM Restricted](https://www.nzism.gcsb.govt.nz/).

| Domain | Control ID | Control Title | Policy | Policy Version |
|---------------|---------------|---------------|---------------|---------------|
|Infrastructure|INF-9|10.8.35 Security Architecture|[Azure Spring App should use network injection](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2Faf35e2a4-ef96-44e7-a9ae-853dd97032c4)|1.1.0|

#### 6. NIST SP 800-53 Rev. 5
To review how the available Azure Policy built-ins for all Azure services map to this compliance standard, see [Azure Policy Regulatory Compliance - NIST SP 800-53 Rev. 5](https://learn.microsoft.com/en-us/azure/governance/policy/samples/nist-sp-800-53-r5). For more information about this compliance standard, see [NIST SP 800-53 Rev. 5](https://nvd.nist.gov/800-53).

| Domain | Control ID | Control Title | Policy | Policy Version |
|---------------|---------------|---------------|---------------|---------------|
|Access Control|AC-17|Remote Access|[Azure Spring App should use network injection](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2Faf35e2a4-ef96-44e7-a9ae-853dd97032c4)|1.1.0|
|Access Control|AC-17 (1)|Monitoring and Control|[Azure Spring App should use network injection](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2Faf35e2a4-ef96-44e7-a9ae-853dd97032c4)|1.1.0|

#### 7. NZ ISM Resticted v3.5
To review how the available Azure Policy built-ins for all Azure services map to this compliance standard, see [Azure Policy Regulatory Compliance - NZ ISM Restricted v3.5](https://learn.microsoft.com/en-us/azure/governance/policy/samples/nz_ism_restricted_v3_5). For more information about this compliance standard, see [NZ ISM Restricted v3.5](https://www.nzism.gcsb.govt.nz/ism-document).

| Domain | Control ID | Control Title | Policy | Policy Version |
|---------------|---------------|---------------|---------------|---------------|
|Infrastructure|NZISM Security Benchmark INF-9|10.8.35 Security Architecture|[Azure Spring App should use network injection](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2Faf35e2a4-ef96-44e7-a9ae-853dd97032c4)|1.1.0|

#### 8. Reserve Bank of India IT Framerwork for Banks v2016
To review how the available Azure Policy built-ins for all Azure services map to this compliance standard, see [Azure Policy Regulatory Compliance - RBI ITF Banks v2016](https://learn.microsoft.com/en-us/azure/governance/policy/samples/rbi_itf_banks_v2016). For more information about this compliance standard, see [RBI ITF Banks v2016 (PDF)](https://rbidocs.rbi.org.in/rdocs/notification/PDFs/NT41893F697BC1D57443BB76AFC7AB56272EB.PDF).

| Domain | Control ID | Control Title | Policy | Policy Version |
|---------------|---------------|---------------|---------------|---------------|
|Patch/Vulnerability & Change Management| |Patch/Vulnerability & Change Management-7.7|[Azure Spring App should use network injection](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2Faf35e2a4-ef96-44e7-a9ae-853dd97032c4)|1.1.0|
|Patch/Vulnerability & Change Management| |Patch/Vulnerability & Change Management-7.7|[Azure Spring App should use network injection](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2Faf35e2a4-ef96-44e7-a9ae-853dd97032c4)|1.1.0|
|Anti-Phishing| |Anti-Phishing-14.1|[Azure Spring App should use network injection](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2Faf35e2a4-ef96-44e7-a9ae-853dd97032c4)|1.1.0|

------------
