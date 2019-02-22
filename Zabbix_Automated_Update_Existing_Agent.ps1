# Update Zabbix agent on Windows
# Tested on Windows Server 2016, Virtual Machine
# Version 1.0
# Created by Daniel Jean Schmidt
# Last updated 13/02/2019
# Attempts to install the latest version of Zabbix


### SERVICES
############################################################

# Attempts to stop the Zabbix service on the Windows machine
C:\Zabbix\zabbix_agentd.exe --stop

# Attempts to uninstall the Zabbix agent on the Windows machine
C:\Zabbix\zabbix_agentd.exe --uninstall

############################################################


### FILE DIRECTORIES
############################################################

# Creates Zabbix backup destination for Zabbix config file
mkdir C:\Zabbix_Backup

# Backs up the config file
Copy-Item C:\Zabbix\*.conf -Destination C:\Zabbix_Backup

# Deletes the old contents
Remove-Item C:\Zabbix -Force -Recurse

# Creates Zabbix folder again
mkdir C:\Zabbix

# Downloads version 4.0.4 from Zabbix.com to C:\Zabbix
wget "https://www.zabbix.com/downloads/4.0.4/zabbix_agents-4.0.4-win-amd64.zip" -outfile C:\Zabbix\Zabbix-4.0.4.zip

# Imports ZIP
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

# Copies the old config file back into the C:\Zabbix
Copy-Item C:\Zabbix_Backup\*.conf -Destination C:\Zabbix -Force

# Cleans up C:\Zabbix_Backup folder
Remove-Item C:\Zabbix_Backup -Force -Recurse

# Attempts to install the agent with the config in C:\Zabbix
C:\Zabbix\zabbix_agentd.exe --config C:\Zabbix\zabbix_agentd.win.conf --install

# Attempts to start the agent
C:\Zabbix\zabbix_agentd.exe --start