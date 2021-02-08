$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path C:\WindowsAzure\Logs\deploydeveloperconfig.log -append
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install azcoyp10 -y --no-progress
choco install vscode -y --no-progress
choco install vscode-java -y --no-progress
choco install vscode-powershell -y --no-progress
choco install vscode-git -y --no-progress
choco install zulu8 -y --no-progress
choco install wsl2 -y --no-progress
choco install maven -y --no-progress
choco install azure-cli -y --no-progress
choco install mysql-cli -y --no-progress
choco install jq -y --no-progress
choco install git -y --no-progress
Stop-Transcript
