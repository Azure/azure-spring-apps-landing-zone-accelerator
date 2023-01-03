CD ..

Get-ChildItem -Directory | Sort-Object name -Descending | ForEach-Object {
	write-warning  $_.FullName
	cd $_.FullName
	
	terraform plan -destroy -out my.plan --var-file ../parameters.tfvars

	if ($lastexitcode -ne 0) { exit }

	terraform apply my.plan

	if ($lastexitcode -ne 0) { exit }

}

#az group delete --name "springlza-APPGW" -y
#az group delete --name "springlza-SpringApps" -y
#az group delete --name "springlza-SHARED" -y
#az group delete --name "springlza-SPOKE" -y
#az group delete --name "springlza-HUB" -y

