# Temporary testing Intructions 

## Configure deployment parameters
Modify parameters.tfvars as needed
Sample:
```
    # The Region to deploy to
    location              = "westus3"

    # This Prefix will be used on most deployed resources
    name_prefix           = "springlza"

    # If using a different name for the Hub Vnet, specify it here
    Hub_Vnet_Name         = "springlza-vnet-HUB"
    Hub_Vnet_RG           = "springlza-HUB"
```

## Deploy all components at once
This will run a PowerShell script that will deploy each component in the appropiate order. You will be prompted for a username and password for the Jump Host.
```
    az login
    cd Deploy
    ./deploy.ps1
```

## Deploy individual components
Use this to deploy each component individually.  It is important to include the --var-file parameter on each run.
```
    az login
    cd <xx-FolderName>
    terraform init --upgrade
    terraform plan -out my.plan --var-file ../parameters.tfvars
    terraform apply my.plan
```

## Clean up
This will run a PowerShell script that will destroy the terraform deployment
```
    az login
    cd Deploy
    ./_destroy.ps1
```


# Project

> This repo has been populated by an initial template to help get you started. Please
> make sure to update the content to build a great experience for community-building.

As the maintainer of this project, please make a few updates:

- Improving this README.MD file to provide a great experience
- Updating SUPPORT.MD with content about this project's support experience
- Understanding the security reporting process in SECURITY.MD
- Remove this section from the README

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
