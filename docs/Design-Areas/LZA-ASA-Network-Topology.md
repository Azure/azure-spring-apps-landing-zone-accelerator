<!-- Landing Zone Accelerator - Azure Spring App -Network Topology And Connectivity.MD v1 -->

## Network topology and connectivity considerations for Azure Spring Apps

This article provides design considerations and recommendations for network topology and connectivity when using the Azure Spring Apps landing zone accelerator. Networking is central to almost everything inside a landing zone.

### Design considerations

#### Networking Requirements

- Consider the use of a Hub and Spoke topology.  The hub virtual network acts as a central point of connectivity to many spoke virtual networks. The hub can also be used as the connectivity point to your on-premises networks. The spoke virtual networks peer with the hub and can be used to isolate workloads. 
- Azure Spring Apps requires two dedicated subnets – one for the service runtime and another for the applications themselves. These subnets should be sized  according to the number of applications and scalability requirements of these applications.
- Azure Spring Apps supports deploying spring apps in your own managed virtual network. Consider this approach to isolate Azure Spring Apps    service runtime and/or app instances from the internet, enable Azure Spring apps to interact with on-premises datacenters or with Azure services in another virtual network. 
- If you are planning to use existing subnets or decide to bring your own route tables, make sure that rules added by Azure  Spring Apps are not updated or deleted. ￼    .
- If your application requires restricted and secured connectivity to your Azure Spring Apps, consider using a service like Azure Bastion to securely connect and manage your application instances. 

#### Considerations for traffic from and to Azure Spring Apps

- Outbound (egress) network traffic can be sent through an Azure Firewall or network virtual appliance.  
- For egress traffic to external users, Azure Spring Apps provides a standard load balancer and automatically configures egress paths by default. Determine if this meets your requirements or if you want to customize this further using User Defined Routing (UDR), for instance to route all traffic through a Network Virtual Appliance (NVA). This consideration is important since you cannot change the outbound traffic type of an Azure Spring Apps instance after it has been created    
- For ingress traffic into Azure Spring Apps, consider using a reverse proxy  . Azure Spring Apps supports several common services such as Azure Application Gateway, Azure Front Door, regional services such as Azure APIM or even non-Azure services.

### Design Recommendations

#### Hub and Spoke Design

- Azure recommends using a Hub and Spoke design with Network Security Groups to filter east-west traffic  (e.g. restricting traffic to your service runtime subnet) and Azure Firewall for north-south traffic (e.g. egress traffic to the internet).  
- The Hub virtual network communicates with the internet while the Spoke virtual network hosts Azure Spring Apps.
 
#### Networking Requirements

- Azure Spring Apps require two dedicated subnets
  - Service Runtime
  - Spring Boot Applications
- The minimum CIDR block size of each of these subnets is /28. Each subnet can only include a single Spring Apps service instance    
- The [number of spring apps](https://learn.microsoft.com/en-us/azure/spring-apps/how-to-deploy-in-azure-virtual-network?tabs=azure-portal#using-smaller-subnet-ranges) that you can deploy within an instance depends on the size of the subnet.
- Azure Spring Apps requires [Owner permission](https://learn.microsoft.com/en-us/azure/spring-apps/how-to-deploy-in-azure-virtual-network?tabs=azure-portal#grant-service-permission-to-the-virtual-network) to your Virtual Network. This is required to grant a dedicated and dynamic service principal for deployment and maintenance.
- Resource Groups and subnets managed by Azure Spring Apps deployment must not be modified
- Azure Spring Apps deployed in a private network provides a fully qualified domain name (FQDN) that is accessible only within the private network. This can be [provisioned](https://learn.microsoft.com/en-us/azure/spring-apps/access-app-virtual-network?tabs=azure-portal) by creating an Azure Private DNS Zone for the IP address of your spring app, linking the private DNS to your virtual network and finally by assigning a private FQDN within Azure Spring Apps.
 
#### Traffic from external users into Spring Apps

- Azure Spring Apps can be deployed either within a virtual network or outside a virtual network i.e. within your own vnet   . Irrespective of the scenario, it is recommended to expose your workloads to the public internet using Azure Application Gateway as a reverse proxy and ensure that your workloads are accessible only through the reverse proxy. This safeguard helps to prevent malicious users from trying to bypass the WAF or circumvent throttling limits, for example.
- The Application Gateway sits in front of Azure Spring Apps instance in its own dedicated subnet.
- Use the assigned endpoint of the Spring Cloud Gateway app as the back-end pool of the Application Gateway. This endpoint resolves to a private IP address in the Azure Spring Apps' Service Runtime subnet.
- Add an NSG on the Service Runtime subnet that allows traffic only from the Application Gateway subnet, Spring Apps subnet and Azure Load Balancer.
 
> [!NOTE]
>- Alternate solutions for the reverse proxy such as Azure Front Door or non-Azure services will require [additional considerations](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/microservices/spring-cloud-reverse-proxy)
>- While the above section addresses considerations when Azure Spring Apps are deployed in a VNet, note that you can also [deploy Azure Spring Apps outside a VNet](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/microservices/spring-cloud-reverse-proxy#azure-spring-apps-deployed-outside-your-virtual-network).
 
#### Traffic from Spring Apps

- By default, Azure Spring Apps has unrestricted outbound internet access (egress). Azure Firewall is recommended to filter egress traffic. Note however that egress traffic to Azure Spring components is required to support the service instances. [Learn more](https://learn.microsoft.com/en-us/azure/spring-apps/vnet-customer-responsibilities) about specific end points and ports that Azure Spring Apps uses.
- Azure Spring Apps provide a [User Defined Route](https://learn.microsoft.com/en-us/azure/spring-apps/concept-outbound-type) Outbound Type to fully control egress traffic path. 

> [!IMPORTANT]
>- OutboundType should be defined when a new Azure Spring Apps service instance is created. It cannot be updated afterwards. 
>- OutboundType can be configured only with a virtual network .
- It is always recommended to use Azure Private Link for supported services if private connectivity is required by your applications.  
