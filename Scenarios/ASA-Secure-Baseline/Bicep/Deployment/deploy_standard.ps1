param($SpecificModules)

$timeStamp = Get-Date -Format "yyyyMMddHHmm"

if ($null -eq $location -or $null -eq $namePrefix) {

    Write-host "Please set the following variables before running this script"
    Write-host '   $location - this should match standard Azure region naming convention, such as "eastus" or "westeurope"'
    Write-host '   $namePrefix - this is a user defined value that will be used to name all resources in this deployment'
    write-host 'See Bicep/README.md for more information'
    break
}
else {

    Write-host "Bicep State Configuration:"
    Write-host "  Location (Azure Region) : $location"
    Write-host "  Name Prefix             : $namePrefix"
}

$principalId = (az ad sp show --id e8de9221-a19c-4c81-b814-fd37c6caf9d2 --query id --output tsv)

az deployment sub create --name "$($timeStamp)-$(Split-Path -Path $PWD -Leaf)" --location $location --template-file "../main.bicep" --parameters "../main.parameters.json" location=$location namePrefix=$namePrefix principalId=$principalId
