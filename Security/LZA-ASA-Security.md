<!-- Landing Zone Accelerator - Azure Spring App -Security.MD v2 -->

### Introduction
This document walks through aspects of Azure Spring Apps (ASA) security governance to think about before implementing any solution.

Most of this content is technology-agnostic, because implementation varies among customers. The article focuses on how to implement solutions using Azure and open-source software. The decisions made when you create an enterprise-scale landing zone can partially predefine your governance. It's important to understand governance principles because of the effect of the decisions made.

Azure Spring Apps is the new name for the Azure Spring Cloud service. Although the service has a new name, you'll see the old name in some places for a while as we work to update assets such as screenshots, videos, and diagrams.
Security controls are built into Azure Spring Apps Service.

A security control is a quality or feature of an Azure service that contributes to the service's ability to prevent, detect, and respond to security vulnerabilities. For each control, we use Yes or No to indicate whether it is currently in place for the service. We use N/A for a control that is not applicable to the service.

### Azure Spring Apps Landing Zone - Topology
Pending

### Azure Spring Apps Landing Zone - Azure Components
Pending 
| Component | Version | Location |
|-------------|---------------|---------------|
|-------------|---------------|---------------|
|-------------|---------------|---------------|
|-------------|---------------|---------------|
|-------------|---------------|---------------|
|-------------|---------------|---------------|
|

### Design Considerations
#### Azure Security Baseline for Azure Spring Cloud Service
This security baseline applies guidance from the [Azure Security Benchmark version 2.0](https://learn.microsoft.com/en-us/security/benchmark/azure/overview-v2) to Azure Spring Cloud Service.  The Azure Security Benchmark provides recommendations on how you can secure your cloud solutions on Azure. The content is grouped by the security controls defined by the Azure Security Benchmark and the related guidance applicable to Azure Spring Cloud Service.

You can monitor this security baseline and its recommendations using Microsoft Defender for Cloud. Azure Policy definitions will be listed in the Regulatory Compliance section of the Microsoft Defender for Cloud dashboard.

When a section has relevant Azure Policy Definitions, they are listed in this baseline to help you measure compliance to the Azure Security Benchmark controls and recommendations. Some recommendations may require a paid Microsoft Defender plan to enable certain security scenarios.

Controls not applicable to Azure Spring Cloud Service, and those for which the global guidance is recommended verbatim, have been excluded. To see how Azure Spring Cloud Service completely maps to the Azure Security Benchmark, see the full [Azure Spring Cloud Service security baseline mapping file](https://github.com/MicrosoftDocs/SecurityBenchmarks/blob/master/Azure Offer Security Baselines/2.0/azure-spring-cloud-service-security-baseline-v2.0.xlsx).

#### Data Protection Security Controls
| Security Control | Yes/No | Notes | Documentation |
|-------------|---------------|---------------|---------------|
|Server-side encryption at rest: | Yes | User uploaded source and artifacts, config server settings, app settings, and data in persistent storage are stored in Azure | [Azure Storage encryption for data at REST](https://learn.microsoft.com/en-us/azure/storage/common/storage-service-encryption)|
|Microsoft-Managed Keys|---------------|---------------|---------------|
|Encryption in transient|---------------|---------------|---------------|
|API calls encrypted|---------------|---------------|---------------|
|Customer Lockbox|---------------|---------------|---------------|





### Network Access Security Controls
### Micrsoft Defender for Cloud Monitoring
### Azure Policy Built-in Definitions - Microsoft.AppPlatform
## Design Recommendations
### Azure Policy Regulatory Compliance Controls for Azure Spring Apps
### Azure Security Benchmark
### FedRAMP High
### FedRAMP Moderate
### New Zealand ISM Restricted
### NIST SP 800-53 Rev. 5
### NZ ISM Resticted v3.5
### Reserve Bank of India IT Framerwork for Banks v2016
## Appendix A: Checklists

<!-- END of Landing Zone Accelerator - Azure Spring App -Security.MD v2 -->


