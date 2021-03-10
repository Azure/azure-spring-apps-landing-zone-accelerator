$ErrorActionPreference="SilentlyContinue"
$LogPath = 'C:\WindowsAzure\Logs\deploydeveloperconfig.log'
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path $LogPath -append
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install azcoyp10 -y --no-progress --log-file=$LogPath
choco install vscode -y --no-progress --log-file=$LogPath
choco install vscode-java -y --no-progress --log-file=$LogPath
choco install vscode-powershell -y --no-progress --log-file=$LogPath
choco install vscode-git -y --no-progress --log-file=$LogPath
choco install zulu8 -y --no-progress --log-file=$LogPath
choco install wsl2 -y --no-progress --log-file=$LogPath
choco install maven -y --no-progress --log-file=$LogPath
choco install azure-cli -y --no-progress --log-file=$LogPath
choco install mysql-cli -y --no-progress --log-file=$LogPath
choco install jq -y --no-progress --log-file=$LogPath
choco install git -y --no-progress --log-file=$LogPath
choco install pgcli -y --no-progress --log-file=$LogPath
choco install sqlserver-cmdlineutils -y --no-progress --log-file=$LogPath
Stop-Transcript
