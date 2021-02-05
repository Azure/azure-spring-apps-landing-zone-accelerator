$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path C:\WindowsAzure\Logs\deploydeveloperconfig.log -append
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Module cChoco -MaximumVersion 2.4.1.0 -force
Install-Module ComputerManagementdsc
Set-Location c:\
./DeveloperWorkstation_Config.ps1
Stop-Transcript
