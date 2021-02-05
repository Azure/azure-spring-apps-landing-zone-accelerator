Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Module cChoco -MaximumVersion 2.4.1.0 -force
Install-Module ComputerManagementdsc
Set-Location c:\
./DeveloperWorkstation_Config.ps1
