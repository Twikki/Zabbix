[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Zabbix Powershell script that installs the agent, or updates the agent and configuration 
# Tested on Windows Server 2012, 2012 R2, 2016, 2019
# Version 1.0
# Installs Zabbix Agent 4.4.6 with SSL

#
# Variables
#

# URL to zabbix agent download.
$Url = "https://www.zabbix.com/downloads/4.4.6/zabbix_agent-4.4.6-windows-amd64-openssl.zip"
$GithubToken = "68a9419cf9050cc45b5c9b766da2818090d20a43"
$Githubrepo = "youtubetest"
$newestagentversion = "4.4.6"
$RequredPowershell = 5
$InstalledPowershell = $PSVersionTable.PSVersion.Major
$counter = 0
$ZabbixBackupFolderPath = "C:\zabbixbackup\"
$ZabbixFolderPath = "C:\Zabbix\"

# Checks Powershell version before executing anything, Exits if lower than version 5.
If ($InstalledPowershell -lt $RequredPowershell)
{
   Write-Host "Requred Powershell version is not installed, Required Powershell is version" $RequredPowershell - "But Version" $InstalledPowershell "is installed"
   exit
}


function Unzip
{
    
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

# Function that provides backup for Zabbix folder
Function ZabbixBackup
{

    $FolderPathTest = Test-Path $ZabbixBackupFolderPath
    If ($FolderPathTest -eq $false)

    {
    
    mkdir c:\zabbixbackup
    
    }

    # Copies the files from the zabbix folder to the newly created folder with the date
    Copy-Item $ZabbixFolderPath -Recurse -Destination "C:\zabbixbackup\Backup_$((Get-Date).ToString('dd-MM-yyyy_hh.mm.ss'))"

}


# Function that installs Zabbix agent
Function ZabbixInstall
{

    # Creates Zabbix directory
    mkdir c:\zabbix

    # Creates the scripts folder in the zabbix folder
    mkdir c:\zabbix\scripts

    # Downloads version 4.4.6 with SSL from https://www.zabbix.com/download_agents
    Invoke-WebRequest $url -outfile c:\zabbix\zabbix.zip

    Add-Type -AssemblyName System.IO.Compression.FileSystem

    # Unzipping file to c:\zabbix
    Unzip "c:\zabbix\zabbix.zip" "c:\zabbix"  

    # 32 bit has been removed in V. 4.4.6, so it's copying the only Agent file.
    Move-Item C:\zabbix\bin\zabbix_agentd.exe -Destination c:\zabbix\

    # Removes the original config file
    Remove-Item C:\zabbix\conf\zabbix_agentd.conf

    # Downloads the latest configuration file from Github.com
    $configfileagent = Invoke-RestMethod https://api.github.com/repos/Twikki/$Githubrepo/contents/zabbix_agentd.win.conf?access_token=$GithubToken -Headers @{”Accept”= “application/vnd.github.v3.raw”}

    #Places the config file in c:\zabbix
    Set-Content -Path 'C:\zabbix\zabbix_agentd.win.conf' -Value $configfileagent


    # Downloads the latest metadata file from Github.com
    $configfilemetadata = Invoke-RestMethod https://api.github.com/repos/Twikki/$Githubrepo/contents/zabbix_agentd.metadata.conf?access_token=$GithubToken -Headers @{”Accept”= “application/vnd.github.v3.raw”}

    # Places the metadata file in c:\zabbix
    Set-Content -Path 'C:\zabbix\conf\zabbix_agentd.metadata.conf' -Value $configfilemetadata


    # Downloads the latest userparam file from Github.com
    $configfileuserparam = Invoke-RestMethod https://api.github.com/repos/Twikki/$Githubrepo/contents/zabbix_agentd.userparams.conf?access_token=$GithubToken -Headers @{”Accept”= “application/vnd.github.v3.raw”}

    # Places the userparam file in c:\zabbix
    Set-Content -Path 'C:\zabbix\conf\zabbix_agentd.userparams.conf' -Value $configfileuserparam

    # Downloads the latest show_config_versions.ps1 file from Github.com
    $configversions = Invoke-RestMethod https://api.github.com/repos/Twikki/$Githubrepo/contents/show_config_versions.ps1?access_token=$GithubToken -Headers @{”Accept”= “application/vnd.github.v3.raw”}

    # Places the show_config_versions.ps1 file in c:\zabbix\scripts
    Set-Content -Path 'C:\zabbix\scripts\show_config_versions.ps1' -Value $configversions

    # Downloads the latest show_agent_Version.ps1 file from Github.com
    $agentversion = Invoke-RestMethod https://api.github.com/repos/Twikki/$Githubrepo/contents/show_agent_version.ps1?access_token=$GithubToken -Headers @{”Accept”= “application/vnd.github.v3.raw”}

    # Places the show_agent_version.ps1 file in c:\zabbix\scripts
    Set-Content -Path 'C:\zabbix\scripts\show_agent_version.ps1' -Value $agentversion


    # Attempts to install the agent with the config in c:\zabbix
    c:\zabbix\zabbix_agentd.exe --config c:\zabbix\zabbix_agentd.win.conf --install

    # Attempts to start the agent
    c:\zabbix\zabbix_agentd.exe --start

}

# Function that Uninstalls Zabbix agent
Function ZabbixUninstall
{

    # Attempts to stop the Zabbix service on the Windows machine
    c:\zabbix\zabbix_agentd.exe --stop

    # Attempts to uninstall the Zabbix agent on the Windows machine
    c:\zabbix\zabbix_agentd.exe --uninstall
    
    # Cleans up in c:\
    Remove-Item c:\zabbix -Force -Recurse

    # Cleans up logs in c:\
    Remove-Item c:\zabbix_agentd.log

}


# Function that Maintains Zabbix configuration files
Function ZabbixMaintain
{ # Open the Zabbix Uninstall function bracket


# Makes a directory for temporary files
mkdir c:\zabbix\maintain

# Checks if zabbix_agentd.win.conf file exists on the server. If yes, it pulls the latest version from Github
$ChkFile = "C:\Zabbix\zabbix_agentd.win.conf"
$FileExists = Test-Path $ChkFile
If ($FileExists -eq $True) {

    $configfileagent = Invoke-RestMethod https://api.github.com/repos/Twikki/$Githubrepo/contents/zabbix_agentd.win.conf?access_token=$GithubToken -Headers @{”Accept”= “application/vnd.github.v3.raw”}

    Set-Content -Path 'C:\zabbix\maintain\zabbix_agentd.win.conf' -Value $configfileagent

    # compares the file downloaded from Github with the existing file on the server. And replaces it if there is a content difference
    if(Compare-Object -ReferenceObject $(Get-Content C:\zabbix\maintain\zabbix_agentd.win.conf) -DifferenceObject $(Get-Content c:\zabbix\zabbix_agentd.win.conf))

 {Move-Item "C:\zabbix\maintain\zabbix_agentd.win.conf" "C:\zabbix\zabbix_agentd.win.conf" -Force

 $counter++

}


}



# Checks if Zabbix_Agentd.userparams.conf file exists on the server. If yes, it pulls the latest version from Github
$ChkFile = "C:\Zabbix\conf\zabbix_agentd.userparams.conf"
$FileExists = Test-Path $ChkFile
If ($FileExists -eq $True) {

    $configfileagent = Invoke-RestMethod https://api.github.com/repos/Twikki/$Githubrepo/contents/zabbix_agentd.userparams.conf?access_token=$GithubToken -Headers @{”Accept”= “application/vnd.github.v3.raw”}

    Set-Content -Path 'C:\zabbix\maintain\zabbix_agentd.userparams.conf' -Value $configfileagent

    # compares the file downloaded from Github with the existing file on the server. And replaces it if there is a content difference
    if(Compare-Object -ReferenceObject $(Get-Content C:\zabbix\maintain\zabbix_agentd.userparams.conf) -DifferenceObject $(Get-Content c:\zabbix\conf\zabbix_agentd.userparams.conf))

 {Move-Item "C:\zabbix\maintain\zabbix_agentd.userparams.conf" "C:\zabbix\conf\zabbix_agentd.userparams.conf" -Force

 $counter++

}


}

# Checks if zabbix_agentd.metadata.conf file exists on the server. If yes, it pulls the latest version from Github
$ChkFile = "C:\Zabbix\conf\zabbix_agentd.metadata.conf"
$FileExists = Test-Path $ChkFile
If ($FileExists -eq $True) {

    $configfileagent = Invoke-RestMethod https://api.github.com/repos/Twikki/$Githubrepo/contents/zabbix_agentd.metadata.conf?access_token=$GithubToken -Headers @{”Accept”= “application/vnd.github.v3.raw”}

    Set-Content -Path 'C:\zabbix\maintain\zabbix_agentd.metadata.conf' -Value $configfileagent

    # compares the file downloaded from Github with the existing file on the server. And replaces it if there is a content difference
    if(Compare-Object -ReferenceObject $(Get-Content C:\zabbix\maintain\zabbix_agentd.metadata.conf) -DifferenceObject $(Get-Content c:\zabbix\conf\zabbix_agentd.metadata.conf))

 {Move-Item "C:\zabbix\maintain\zabbix_agentd.metadata.conf" "C:\zabbix\conf\zabbix_agentd.metadata.conf" -Force

 $counter++

}


}

# Checks if show_config_versions.ps1 file exists on the server. If yes, it pulls the latest version from Github
$ChkFile = "C:\Zabbix\scripts\show_config_versions.ps1"
$FileExists = Test-Path $ChkFile
If ($FileExists -eq $false) 
{

    # Downloads the latest show_config_versions.ps1 file from Github.com
    $configversions = Invoke-RestMethod https://api.github.com/repos/Twikki/$Githubrepo/contents/show_config_versions.ps1?access_token=$GithubToken -Headers @{”Accept”= “application/vnd.github.v3.raw”}

    # Places the show_config_versions.ps1 file in c:\zabbix\scripts
    Set-Content -Path 'C:\zabbix\scripts\show_config_versions.ps1' -Value $configversions

$counter ++

}
else
{

    $configfileagent = Invoke-RestMethod https://api.github.com/repos/Twikki/$Githubrepo/contents/show_config_versions.ps1?access_token=$GithubToken -Headers @{”Accept”= “application/vnd.github.v3.raw”}

    Set-Content -Path 'C:\zabbix\maintain\show_config_versions.ps1' -Value $configfileagent

    # compares the file downloaded from Github with the existing file on the server. And replaces it if there is a content difference
    if(Compare-Object -ReferenceObject $(Get-Content C:\zabbix\maintain\show_config_versions.ps1) -DifferenceObject $(Get-Content c:\zabbix\scripts\show_config_versions.ps1))

 {Move-Item "C:\zabbix\maintain\show_config_versions.ps1" "C:\zabbix\scripts\show_config_versions.ps1" -Force

 $counter++

}

}

# Checks if show_agent_version.ps1 file exists on the server. If yes, it pulls the latest version from Github
$ChkFile = "C:\Zabbix\scripts\show_agent_version.ps1"
$FileExists = Test-Path $ChkFile
If ($FileExists -eq $false) 
{

    # Downloads the latest show_agent_Version.ps1 file from Github.com
    $agentversion = Invoke-RestMethod https://api.github.com/repos/Twikki/$Githubrepo/contents/show_agent_version.ps1?access_token=$GithubToken -Headers @{”Accept”= “application/vnd.github.v3.raw”}

    # Places the show_agent_version.ps1 file in c:\zabbix\scripts
    Set-Content -Path 'C:\zabbix\scripts\show_agent_version.ps1' -Value $agentversion

$counter ++

}
else
{

    $configfileagent = Invoke-RestMethod https://api.github.com/repos/Twikki/$Githubrepo/contents/show_agent_version.ps1?access_token=$GithubToken -Headers @{”Accept”= “application/vnd.github.v3.raw”}

    Set-Content -Path 'C:\zabbix\maintain\show_agent_version.ps1' -Value $configfileagent

    # compares the file downloaded from Github with the existing file on the server. And replaces it if there is a content difference
    if(Compare-Object -ReferenceObject $(Get-Content C:\zabbix\maintain\show_agent_version.ps1) -DifferenceObject $(Get-Content c:\zabbix\scripts\show_agent_version.ps1))

 {Move-Item "C:\zabbix\maintain\show_agent_version.ps1" "C:\zabbix\scripts\show_agent_version.ps1" -Force

$counter ++
 
}

}


# This will restart the agent if counter is equal to 1 or above
If ($counter -ge 1) 

    {

    Write-Host $Counter "Files has been updated! Restarting agent..."
    # Attempts to stop the agent
    c:\zabbix\zabbix_agentd.exe --stop
    
    # Attempts to start the agent
    c:\zabbix\zabbix_agentd.exe --start
    
    
    }
    
    # Cleans up old files
    Remove-Item C:\zabbix\maintain -Force -Recurse




# Closing the Zabbix Uninstall function bracket
}


#
# Installation script starts here
#

# Checks if the Zabbix folder exists.
$ChkFile = "C:\Zabbix\"
$FileExists = Test-Path $ChkFile
If ($FileExists -eq $True) 

{

    # Gets the version that is currently installed on the server, and then determine what to do.
    $currentagentversion = (Get-Item C:\Zabbix\zabbix_agentd.exe).VersionInfo.ProductVersion

    # If versions match, do this.
    If ($currentagentversion -eq $newestagentversion)
    {
        Write-Host "Detected that Zabbix agent Version is the same, updating configuration files!"
        ZabbixMaintain
    }
    else
    {
        Write-Host "Detected that Zabbix agent version is NOT the same, updating agent to newest version!" $newestagentversion
        ZabbixBackup
        ZabbixUninstall
        ZabbixInstall    
    }

}
else
{
    Write-Host "Detected that Zabbix agent is not installed on this Windows machine. Installing agent version!" $newestagentversion
    ZabbixInstall    
}