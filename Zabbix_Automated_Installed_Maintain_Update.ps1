# Short description of script
# THIS IS USED FOR INDIVIDUAL SERVERS!
# Installs the Zabbix agent if not installed, maintains the agent if installed, or updates the agent if not up to date.
# This script will be using private Github repositories for maintaining the files

# Powershell sometimes needs to be forced to use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Varibles needed throughout the Script
# Download link for the agent
$Url = "https://www.zabbix.com/downloads/4.2.6/zabbix_agents-4.2.6-win-amd64.zip"
$newestagentversion = "4.2.6"
# Powershell version 5 is required for this to work properly.
$RequredPowershell = 5
$InstalledPowershell = $PSVersionTable.PSVersion.Major
# The counter is used later to determine if a restart of the agent is needed
$counter = 0
$ZabbixBackupFolderPath = "C:\zabbixbackup\"
$ZabbixFolderPath = "C:\Zabbix\"

# Checks Powershell version before executing anything, Exits if lower than version 5.
If ($InstalledPowershell -lt $RequredPowershell)
{
   Write-Host "Requred Powershell version is not installed, Required Powershell is version" $RequredPowershell - "But Version" $InstalledPowershell "is installed"
   exit
}


####
#### BUILDING FUNCTIONS HERE
####

# Function that unzips a file
function Unzip
{
    
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

# Function that provides backup for Zabbix folder with detailed information
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

    # Downloads version 4.2.6 from https://www.zabbix.com/download_agents
    Invoke-WebRequest $url -outfile c:\zabbix\zabbix.zip

    Add-Type -AssemblyName System.IO.Compression.FileSystem

    # Unzipping file to c:\zabbix
    Unzip "c:\zabbix\zabbix.zip" "c:\zabbix"  

    # Looks like 32 bit has been removed in V. 4.2.6, so it's copying the only Agent file.
    Move-Item C:\zabbix\bin\zabbix_agentd.exe -Destination c:\zabbix\

    # Removes the original config file
    Remove-Item C:\zabbix\conf\zabbix_agentd.conf

    # Downloads the latest configuration file from Github.com
    $configfileagent = Invoke-RestMethod https://api.github.com/repos/YourCompanyHere/YourRepoHere/contents/zabbix_agentd.win.conf?access_token=YourAccessTokenHere -Headers @{”Accept”= “application/vnd.github.v3.raw”}

    #Places the config file in c:\zabbix
    Set-Content -Path 'C:\zabbix\zabbix_agentd.win.conf' -Value $configfileagent

    # Downloads the latest metadata file from Github.com
    $configfilemetadata = Invoke-RestMethod https://api.github.com/repos/YourCompanyHere/YourRepoHere/contents/zabbix_agentd.metadata.conf?access_token=YourAccessTokenHere -Headers @{”Accept”= “application/vnd.github.v3.raw”}

    # Places the metadata file in c:\zabbix
    Set-Content -Path 'C:\zabbix\conf\zabbix_agentd.metadata.conf' -Value $configfilemetadata

    # Downloads the latest userparam file from Github.com
    $configfileuserparam = Invoke-RestMethod https://api.github.com/repos/YourCompanyHere/YourRepoHere/contents/zabbix_agentd.userparams.conf?access_token=YourAccessTokenHere -Headers @{”Accept”= “application/vnd.github.v3.raw”}

    # Places the userparam file in c:\zabbix
    Set-Content -Path 'C:\zabbix\conf\zabbix_agentd.userparams.conf' -Value $configfileuserparam

    # Attempts to install the agent with the config in c:\zabbix
    c:\zabbix\zabbix_agentd.exe --config c:\zabbix\zabbix_agentd.win.conf --install

    # Attempts to start the agent
    c:\zabbix\zabbix_agentd.exe --start

}

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
# Function open
{                                          


# Makes a directory for temporary files
mkdir c:\zabbix\maintain


# Checks if zabbix_agentd.win.conf file exists on the server. If yes, it pulls the latest version from Github
$ChkFile = "C:\Zabbix\zabbix_agentd.win.conf"
$FileExists = Test-Path $ChkFile
If ($FileExists -eq $True) {

    $configfileagent = Invoke-RestMethod https://api.github.com/repos/YourCompanyHere/YourRepoHere/contents/zabbix_agentd.win.conf?access_token=YourAccessTokenHere -Headers @{”Accept”= “application/vnd.github.v3.raw”}

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

    $configfileagent = Invoke-RestMethod https://api.github.com/repos/YourCompanyHere/YourRepoHere/contents/zabbix_agentd.userparams.conf?access_token=YourAccessTokenHere -Headers @{”Accept”= “application/vnd.github.v3.raw”}

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

    $configfileagent = Invoke-RestMethod https://api.github.com/repos/YourCompanyHere/YourRepoHere/contents/zabbix_agentd.metadata.conf?access_token=YourAccessTokenHere -Headers @{”Accept”= “application/vnd.github.v3.raw”}

    Set-Content -Path 'C:\zabbix\maintain\zabbix_agentd.metadata.conf' -Value $configfileagent

    # compares the file downloaded from Github with the existing file on the server. And replaces it if there is a content difference
    if(Compare-Object -ReferenceObject $(Get-Content C:\zabbix\maintain\zabbix_agentd.metadata.conf) -DifferenceObject $(Get-Content c:\zabbix\conf\zabbix_agentd.metadata.conf))

 {Move-Item "C:\zabbix\maintain\zabbix_agentd.metadata.conf" "C:\zabbix\conf\zabbix_agentd.metadata.conf" -Force

 $counter++

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


# Function closing
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