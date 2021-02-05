$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path C:\WindowsAzure\Logs\deploydeveloperconfig.log -append
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Install-Module cChoco -MaximumVersion 2.4.1.0 -force
Install-Module ComputerManagementdsc
copy DeveloperWorkstation_Config.ps1 -destination C:\
Set-Location c:\
./DeveloperWorkstation_Config.ps1
Stop-Transcript
