CD ..
Get-ChildItem -Directory | foreach {
	write-warning  $_.FullName
	cd $_.FullName
	terraform init --upgrade
	terraform plan -out my.plan --var-file ../parameters.tfvars

	if ($lastexitcode -ne 0) { exit }

	terraform apply my.plan

	if ($lastexitcode -ne 0) { exit }

	# Wait 30 seconds between Apply
	Write-warning "Waiting 15 seconds...."
	Sleep 15
}