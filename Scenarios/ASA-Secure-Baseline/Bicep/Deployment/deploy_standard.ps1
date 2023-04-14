param($SpecificModules)

$timeStamp = Get-Date -Format "yyyyMMddHHmm"

if ($null -eq $location -or $null -eq $namePrefix ) {

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

# Deploy the modules
$Modules = @()

if ($null -eq $SpecificModules) {
    if ($ENV:SkipHub -ne "true") { $Modules += "02-Hub-Network" }
    $Modules += "03-LZ-Network"
    $Modules += "04-LZ-SharedResources"
    if ($ENV:SkipFirewall -ne "true") { $Modules += "05-Hub-AzureFirewall" }
    $Modules += "06-LZ-SpringApps-Standard"
}
else {
    $Modules = $SpecificModules
}

$Modules | ForEach-Object {
    Write-Warning  "Working on $_ ..."
    Set-Location "..\$_"

    if (Test-Path -Path "main.bicep") {

        az deployment sub create --name "$($timeStamp)-$(Split-Path -Path $PWD -Leaf)" --location $location --template-file "main.bicep" --parameters parameters.json location=$location namePrefix=$namePrefix

        if ($lastexitcode -ne 0) { exit }
  
        # Wait 150 seconds between Apply
        Write-Warning "Waiting 15 seconds...."
        Start-Sleep 15
    }
    else {
        Write-Warning "No Bicep file found in $($_)"
    }
}

Set-Location "..\Deployment"