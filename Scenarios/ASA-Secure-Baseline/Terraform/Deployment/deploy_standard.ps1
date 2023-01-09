#Deploy the Hub first
cd ..\02-Hub-Network

terraform init -backend-config="resource_group_name=$TFSTATE_RG" -backend-config="storage_account_name=$STORAGEACCOUNTNAME" -backend-config="container_name=$CONTAINERNAME"
terraform plan -out my.plan --var-file ../parameters.tfvars
terraform apply my.plan

# Deploy the rest
$Modules= "03-LZ-Network", `
		  "04-LZ-SharedResources", `
		  "05-Hub-AzureFirewall", `
		  "06-LZ-SpringApps-Standard"

		  $Modules | ForEach-Object {
	write-warning  $_
	cd ..\$_
	terraform init -backend-config="resource_group_name=$TFSTATE_RG" -backend-config="storage_account_name=$STORAGEACCOUNTNAME" -backend-config="container_name=$CONTAINERNAME"

	terraform plan -out my.plan --var-file ../parameters.tfvars

	if ($lastexitcode -ne 0) { exit }

	terraform apply my.plan

	if ($lastexitcode -ne 0) { exit }

	# Wait 30 seconds between Apply
	Write-warning "Waiting 15 seconds...."
	Start-Sleep 15
}