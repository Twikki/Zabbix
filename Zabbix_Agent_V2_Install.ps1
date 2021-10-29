#
# THIS SCRIPT IS READY TO USE
#

# Install Zabbix agent V2 on Windows
# This script is designed for automatic install and maintenance via Endpoint manager
# Tested on Windows 10
# Version 1.02
# Created by Twikki
# Last updated 29/10/2021


# Download links for different versions 
# 
$versionssl = "https://cdn.zabbix.com/zabbix/binaries/stable/5.4/5.4.7/zabbix_agent2-5.4.7-windows-amd64-openssl-static.zip"

#Gets the server host name
$serverHostname =  Invoke-Command -ScriptBlock {hostname}

# Asks the user for the IP address of their Zabbix server
$ServerIP = Read-Host -Prompt 'What is your Zabbix server/proxy IP?'

# Creates Zabbix DIR
mkdir c:\zabbix

# Downloads the version you want. Links are up. This script currently as standard downloads version 5.4.7 with SSL option
Invoke-WebRequest "$versionssl" -outfile c:\zabbix\zabbix.zip

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

# Unzipping file to c:\zabbix
Unzip "c:\Zabbix\zabbix.zip" "c:\zabbix"     

# Replaces 127.0.0.1 with your Zabbix server IP in the config file
(Get-Content -Path c:\zabbix\conf\zabbix_agent2.conf) | ForEach-Object {$_ -Replace '127.0.0.1', "$ServerIP"} | Set-Content -Path c:\zabbix\conf\zabbix_agent2.conf

# Replaces hostname in the config file
(Get-Content -Path c:\zabbix\conf\zabbix_agent2.conf) | ForEach-Object {$_ -Replace 'Windows host', "$ServerHostname"} | Set-Content -Path c:\zabbix\conf\zabbix_agent2.conf

# Attempts to install the agent with the config in c:\zabbix
C:\zabbix\bin\zabbix_agent2.exe --config c:\zabbix\conf\zabbix_agent2.conf --install

# Attempts to start the agent
c:\zabbix\bin\zabbix_agent2.exe --start --config C:\zabbix\conf\zabbix_agent2.conf

# Creates a firewall rule for the Zabbix server
New-NetFirewallRule -DisplayName "Allow Zabbix communication" -Direction Inbound -Program "c:\zabbix\bin\zabbix_agent2.exe" -RemoteAddress LocalSubnet -Action Allow
