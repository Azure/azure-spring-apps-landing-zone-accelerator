
# Destroy in reverse order
$Modules= "06-LZ-SpringApps-Enterprise", `
          "06-LZ-SpringApps-Standard", `
		  "05-Hub-AzureFirewall", `
		  "04-LZ-SharedResources", `
          "03-LZ-Network", `
          "02-Hub-Network"
		  
$Modules | ForEach-Object {
	write-warning  $_
	cd ..\$_
	
	if ((test-path ".terraform") -eq $true ) {
		terraform plan -destroy -out my.plan --var-file ../parameters.tfvars

		if ($lastexitcode -ne 0) { exit }

		terraform apply my.plan

		if ($lastexitcode -ne 0) { exit }
	}
}

#az group delete --name "springlza-APPGW" -y
#az group delete --name "springlza-SpringApps" -y
#az group delete --name "springlza-SHARED" -y
#az group delete --name "springlza-SPOKE" -y
#az group delete --name "springlza-HUB" -y

