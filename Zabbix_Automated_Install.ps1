# Install Zabbix agent on Windows
# Tested on Windows Server 2016, Virtual Machine
# Version 1.0
# Created by Daniel Jean Schmidt
# Last updated 13/02/2019
# Installs Zabbix Agent 4.0.4


# Asks the user for the IP address of their Zabbix server
$ServerIP = Read-Host -Prompt 'What is your Zabbix server IP?'


# Deletes Zabbix DIR if already exists
Remove-Item C:\Zabbix -Force

# Creates Zabbix DIR
mkdir C:\Zabbix

# Downloads version 4.0.4 from Zabbix.com
wget "https://www.zabbix.com/downloads/4.0.4/zabbix_agents-4.0.4-win-amd64.zip" -outfile C:\Zabbix\Zabbix-4.0.4.zip

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

# Unzipping file to C:\Zabbix
Unzip "C:\Zabbix\Zabbix-4.0.4.zip" "C:\Zabbix"      


# Sorts files in C:\Zabbix
Move-Item C:\Zabbix\bin\zabbix_agentd.exe -Destination C:\Zabbix


# Sorts files in C:\Zabbix
Move-Item C:\Zabbix\conf\zabbix_agentd.win.conf -Destination C:\Zabbix

# Replaces 127.0.0.1 with your Zabbix server IP
(Get-Content -Path C:\Zabbix\zabbix_agentd.win.conf) | ForEach-Object {$_ -Replace '127.0.0.1', "$ServerIP"} | Set-Content -Path C:\Zabbix\zabbix_agentd.win.conf

# Attempts to install the agent with the config in C:\Zabbix
C:\Zabbix\zabbix_agentd.exe --config C:\Zabbix\zabbix_agentd.win.conf --install

# Attempts to start the agent
C:\Zabbix\zabbix_agentd.exe --start

# Creates a firewall rule for the Zabbix server
New-NetFirewallRule -DisplayName "Allow Zabbix communication" -Direction Inbound -Program "C:\Zabbix\Zabbix_agentd.exe" -RemoteAddress LocalSubnet -Action Allow