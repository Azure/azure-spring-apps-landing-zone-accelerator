if ($TFSTATE_RG -eq $null -or $STORAGEACCOUNTNAME -eq $null -or $CONTAINERNAME -eq $null -or $ENV:ARM_ACCESS_KEY -eq $null -or $ENV:TF_VAR_access_key -eq $null  ) {

	Write-host "Please ensure the following state management variables have been defined, prior to running this script"
	Write-host '   $TFSTATE_RG'
	Write-host '   $STORAGEACCOUNTNAME'
	Write-host '   $CONTAINERNAME'
	Write-Host '   $ENV:ARM_ACCESS_KEY'
	write-host '   $ENV:TF_VAR_access_key'
	break
}

# Jumpbox password - checking for variables
if ($null -eq $ENV:TF_VAR_jump_host_password) {
	Write-warning $('$ENV:TF_VAR_jump_host_password environment variable not set, prompting instead...')

	# If the $ENV:TF_VAR_jump_host_password is not set, then ask
	$tmpSecureString               = Read-Host -Prompt "Provide a JumpBox VM password" -AsSecureString
	$BSTR                          = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($tmpSecureString)
    $ENV:TF_VAR_jump_host_password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
} else {
	Write-Host "Using TF_VAR_jump_host_password for Jump Box VM Password"
}

#Deploy the Hub first
cd ..\02-Hub-Network

terraform init -backend-config="resource_group_name=$TFSTATE_RG" -backend-config="storage_account_name=$STORAGEACCOUNTNAME" -backend-config="container_name=$CONTAINERNAME"
terraform plan -out my.plan --var-file ../parameters.tfvars
terraform apply my.plan

# Deploy the rest
$Modules=@()
$Modules+= "03-LZ-Network"
$Modules+= "04-LZ-SharedResources"
if ($ENV:SkipFirewall -ne "true") { $Modules+= "05-Hub-AzureFirewall" }
$Modules+= "06-LZ-SpringApps-Standard"
		  

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