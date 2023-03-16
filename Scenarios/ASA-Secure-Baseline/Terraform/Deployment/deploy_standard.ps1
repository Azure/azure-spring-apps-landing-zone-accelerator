param($SpecificModules)

if ($TFSTATE_RG -eq $null -or $STORAGEACCOUNTNAME -eq $null -or $CONTAINERNAME -eq $null ) {

	Write-host "Please set the following variables before running this script"
	Write-host '   $TFSTATE_RG'
	Write-host '   $STORAGEACCOUNTNAME'
	Write-host '   $CONTAINERNAME'
	write-host 'See Terraform/01-State-Storage.md for more information'
	break
} else {

    Write-host "Terraform State Configuration:"
	Write-host "  Storage Account Resource Group : $TFSTATE_RG"
	Write-host "  Storage Account Name           : $STORAGEACCOUNTNAME"
	Write-host "  Storage Account Container      : $CONTAINERNAME"
    Write-host "From parameters.tfvars:"
	
	Get-Content ..\parameters.tfvars -ErrorAction SilentlyContinue | Select-String -Pattern "="  | ForEach-Object {
		$TrimmedLine=[string]$_
		
		if ($TrimmedLine.trim() -match "^#|pass|key|secret") {
			<#Exclude this line#>
		}
		
		else {
			$kvpair=$TrimmedLine.trim() -split '='
			Write-host $("  {0}{1}:{2}" -f  $kvpair[0].trim(),(" "*(31-$kvpair[0].trim().length)),$kvpair[1])
		}
	}

}

# Jumpbox password - checking for variables
if ($null -eq $ENV:TF_VAR_jump_host_password) {
	Write-warning $('$ENV:TF_VAR_jump_host_password environment variable not set, prompting instead...')

	# If the $ENV:TF_VAR_jump_host_password is not set, then ask
	$tmpSecureString               = Read-Host -Prompt "Provide a JumpBox VM password" -AsSecureString
	$BSTR                          = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($tmpSecureString)
    $ENV:TF_VAR_jump_host_password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
} else {
	Write-Host "`nUsing TF_VAR_jump_host_password for Jump Box VM Password"
}

# Deploy the modules
$Modules=@()

if ($SpecificModules -eq $null) {
	if ($ENV:SkipHub -ne "true") { $Modules+= "02-Hub-Network" }
	$Modules+= "03-LZ-Network"
	$Modules+= "04-LZ-SharedResources"
	if ($ENV:SkipFirewall -ne "true") { $Modules+= "05-Hub-AzureFirewall" }
	$Modules+= "06-LZ-SpringApps-Standard"
} else {
	$Modules=$SpecificModules
}

		  

$Modules | ForEach-Object {
	write-warning  "Working on $_ ..."
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