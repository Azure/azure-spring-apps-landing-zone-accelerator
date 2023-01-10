
# Destroy in reverse order
$Modules=@()
$Modules+= "06-LZ-SpringApps-Enterprise"
$Modules+= "06-LZ-SpringApps-Standard"
$Modules+= "05-Hub-AzureFirewall"
$Modules+= "04-LZ-SharedResources" 
$Modules+= "03-LZ-Network"
$Modules+= "02-Hub-Network"




$Modules | ForEach-Object {
	write-warning  $_
	cd ..\$_
	
	if ((test-path ".terraform") -eq $true ) {
		terraform plan -destroy -out my.plan --var-file ../parameters.tfvars

		if ($lastexitcode -ne 0) { exit }

		terraform apply my.plan

		if ($lastexitcode -ne 0) { exit }

		remove-item my.plan
		remove-item .terraform.lock.hcl
        remove-item .terraform -Recurse -Confirm:$false
	}
}

#az group delete --name "springlza-APPGW" -y
#az group delete --name "springlza-SpringApps" -y
#az group delete --name "springlza-SHARED" -y
#az group delete --name "springlza-SPOKE" -y
#az group delete --name "springlza-HUB" -y

