# Azure Spring Apps Secure Baseline with VNet Injection

Insert description of scenario here along with diagram

## Core architecture components

* Azure Spring Apps Standard/Enterprise with VNet Injection
* Azure Virtual Networks (hub-spoke)
  * Azure Firewall managed egress
* Azure Bastion
* Azure Firewall
* Azure Application Gateway with WAF (optional)
* Azure Key vault
* Log Analytics Workspace
* Application Insights

## Next
Pick one of the IaC options below and follow the instructions to deploy the Azure Spring Apps reference implementation.

:arrow_forward: [Terraform](./Terraform)

:arrow_forward: [Bicep](./Bicep)