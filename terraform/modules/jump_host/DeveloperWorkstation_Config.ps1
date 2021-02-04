configuration DeveloperWorkstation
{
    Import-DscResource -ModuleName cChoco -ModuleVersion 2.4.1.0
    Import-DscResource -ModuleName ComputerManagementdsc

    Node localhost
    {
        LocalConfigurationManager 
        {
            RebootNodeIfNeeded = $True
            RefreshMode = "Push"
            ConfigurationMode = "ApplyOnly"
            ActionAfterReboot = 'ContinueConfiguration'
        }
        
        PowerShellExecutionPolicy 'ExecutionPolicy'
        {
            ExecutionPolicyScope = 'LocalMachine'
            ExecutionPolicy      = 'RemoteSigned'
        }

        cChocoInstaller InstallChoco
        {
            InstallDir = "C:\choco"
        }
        
        cChocoPackageInstaller installAzureDataStudio
        {
            Name                 = 'azure-data-studio'
            Ensure               = 'Present'
            DependsOn            = '[cChocoInstaller]installChoco'
        }
        cChocoPackageInstaller installAzureDataStudioExt2
        {
            Name                 = 'azuredatastudio-powershell'
            Ensure               = 'Present'
            DependsOn            = '[cChocoPackageInstaller]installAzureDataStudio'
        }
        cChocoPackageInstaller azcopy
        {
            Name                 = 'azcoyp10'
            Ensure               = 'Present'
            DependsOn            = '[cChocoInstaller]installChoco'
        }
        cChocoPackageInstaller vscode
        {
            Name                 = 'vscode'
            Ensure               = 'Present'
            DependsOn            = '[cChocoInstaller]installChoco'
        }
        cChocoPackageInstaller vscodemssql
        {
            Name                 = 'vscode-java'
            Ensure               = 'Present'
            DependsOn            = '[cChocoPackageInstaller]vscode'
        }
        cChocoPackageInstaller vscodepowershell
        {
            Name                 = 'vscode-powershell'
            Ensure               = 'Present'
            DependsOn            = '[cChocoPackageInstaller]vscode'
        }
        cChocoPackageInstaller git
        {
            Name                 = 'git'
            Ensure               = 'Present'
            DependsOn            = '[cChocoInstaller]installChoco'
        }
        cChocoPackageInstaller wsl2
        {
            Name                 = 'wsl2'
            Ensure               = 'Present'
            DependsOn            = '[cChocoInstaller]installChoco'
        }
        cChocoPackageInstaller zulu8
        {
            Name                 = 'zulu8'
            Ensure               = 'Present'
            DependsOn            = '[cChocoInstaller]installChoco'
        }
        cChocoPackageInstaller maven
        {
            Name                 = 'maven'
            Ensure               = 'Present'
            DependsOn            = '[cChocoInstaller]installChoco'
        }
        cChocoPackageInstaller azurecli
        {
            Name                 = 'azure-cli'
            Ensure               = 'Present'
            DependsOn            = '[cChocoInstaller]installChoco'
        }
        cChocoPackageInstaller mysqlcli
        {
            Name                 = 'mysql-cli'
            Ensure               = 'Present'
            DependsOn            = '[cChocoInstaller]installChoco'
        }
        File SourceCodeDir
        {
            Ensure = 'Present'
            Type = 'Directory'
            DestinationPath = 'c:\Source-code'
        }
        cChocoPackageInstaller jq
        {
            Name                 = 'jq'
            Ensure               = 'Present'
            DependsOn            = '[cChocoInstaller]installChoco'
        }
        IEEnhancedSecurityConfiguration 'DisableIeSecurityForAdmin'
        {
            Role = 'Administrators'
            Enabled = $false
            DependsOn = '[cChocoPackageInstaller]jq'
        }
        PendingReboot 'CheckForReboot'
        {
            Name = 'Checkfor Reboot After Disable ID Security'
            DependsOn = '[IEEnhancedSecurityConfiguration]DisableIeSecurityForAdmin'
        }
    }
}

$ConfigData = @{
    AllNodes = @(
    @{
        NodeName = 'localhost'
        PSDscAllowPlainTextPassword = $true
    }
    )
}


 DeveloperWorkstation -Verbose -ConfigurationData $ConfigData -OutputPath C:\Packages\Plugins\Microsoft.Powershell.DSC\2.80.0.0\DSCWork\DeveloperWorkstation.0\DeveloperWorkstation

 Start-DscConfiguration -wait -Force -Verbose -Path C:\Packages\Plugins\Microsoft.Powershell.DSC\2.80.0.0\DSCWork\DeveloperWorkstation.0\DeveloperWorkstation
