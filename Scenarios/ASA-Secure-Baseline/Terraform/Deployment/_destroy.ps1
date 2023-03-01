
# Destroy in reverse order
$Modules=@()
$Modules+= "07-LZ-AppGateway"
$Modules+= "06-LZ-SpringApps-Enterprise"
$Modules+= "06-LZ-SpringApps-Standard"
$Modules+= "05-Hub-AzureFirewall"
$Modules+= "04-LZ-SharedResources" 
$Modules+= "03-LZ-Network"
$Modules+= "02-Hub-Network"




$Modules | ForEach-Object {
	write-warning  "Working on $_ ..."
	cd ..\$_
	
	if ((test-path ".terraform") -eq $true ) {
		terraform plan -destroy -out my.plan --var-file ../parameters.tfvars

		if ($lastexitcode -ne 0) { exit }

		terraform apply my.plan

		if ($lastexitcode -ne 0) { exit }

		remove-item my.plan -ErrorAction SilentlyContinue
		remove-item .terraform.lock.hcl -ErrorAction SilentlyContinue
        remove-item terraform.tfstate.backup -ErrorAction SilentlyContinue
		remove-item terraform.tfstate  -ErrorAction SilentlyContinue
		remove-item .terraform -Recurse   -ErrorAction SilentlyContinue
	}
}



