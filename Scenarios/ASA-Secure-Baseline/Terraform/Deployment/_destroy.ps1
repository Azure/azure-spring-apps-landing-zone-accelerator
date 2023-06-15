
# Destroy in reverse order
$Modules = @()
$Modules += "07-LZ-AppGateway"
$Modules += "06-LZ-SpringApps-Enterprise"
$Modules += "06-LZ-SpringApps-Standard"
$Modules += "05-Hub-AzureFirewall"
$Modules += "04-LZ-SharedResources" 
$Modules += "03-LZ-Network"
$Modules += "02-Hub-Network"

Write-host @"
Please take the following actions before attempting to destroy this deployment.
  - Turn on the Jump Box Virtual Machine
  - If you have deployed Azure Spring apps Enterprise edition, first disable the public endpoint on the Azure Spring apps Enterprise - API Portal    
    Azure Portal > Azure Spring Apps instance > API Portal > Assign endpoint -> Set to No

"@

Write-host "This script will automatically continue in 30 seconds..."
sleep 30



$Modules | ForEach-Object {
	write-warning  "Working on $_ ..."
	cd ..\$_
	
	if ((test-path ".terraform") -eq $true ) {
		terraform plan -destroy -out my.plan --var-file ../parameters.tfvars

		if ($lastexitcode -ne 0) { return }

		terraform apply my.plan

		if ($lastexitcode -ne 0) { exit }

		remove-item my.plan -ErrorAction SilentlyContinue
		remove-item .terraform.lock.hcl -ErrorAction SilentlyContinue
		remove-item terraform.tfstate.backup -ErrorAction SilentlyContinue
		remove-item terraform.tfstate  -ErrorAction SilentlyContinue
		remove-item .terraform -Recurse   -ErrorAction SilentlyContinue
	}
}



