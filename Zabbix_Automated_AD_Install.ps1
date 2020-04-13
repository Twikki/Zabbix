#
# THIS SCRIPT IS READY TO USE
#
# Created by Twikki
# Last updated 13/04/2020

# Short description of script
# THIS IS USED FOR PUSHING ZABBIX AGENTS / UPGRADE AGENTS TO AD joined computers / servers
# Installs the Zabbix agent if not installed, upgrades to prefered version if installed.


function InstallZabbixAD

{

# Zabbix agent version you prefer
$versionssl = "https://www.zabbix.com/downloads/4.4.6/zabbix_agent-4.4.6-windows-amd64-openssl.zip"
$agentversion = "4.4.6"
$ServerProxyIP = "192.168.5.2"



# Starts by checking if Zabbix folder actually exists, if it does, it will not attempt to install Zabbix
$ChkFile = "C:\Zabbix\"
$FileExists = Test-Path $ChkFile

If ($FileExists -eq $True) 

{
$serverHostname =  Invoke-Command -ScriptBlock {hostname}
Write-host "Zabbix already exists on " $serverHostname "Checking if version needs update" -ForegroundColor Green

$currentagentversion = (Get-Item C:\Zabbix\zabbix_agentd.exe).VersionInfo.ProductVersion

# If versions match, continue, else remove old version and install new version
If ($currentagentversion -eq $agentversion)
    {
        # Zabbix agent installed is the prefered version. Do nothing
        Write-Host "Detected that Zabbix agent Version is the same, continuing to  next host.."
    }
else
    {
    
    Write-Host "Detected that Zabbix agent Version is NOT the same, Beginning to upgrade.."
    # Zabbix agent is not the prefered version. Remove old version, and install prefered one.

    # Attempts to stop the Zabbix service on the Windows machine
    c:\zabbix\zabbix_agentd.exe --stop

    # Attempts to uninstall the Zabbix agent on the Windows machine
    c:\zabbix\zabbix_agentd.exe --uninstall
    
    # Cleans up in c:\
    Remove-Item c:\zabbix -Force -Recurse

    # Cleans up logs in c:\
    Remove-Item c:\zabbix_agentd.log

    # Everything has been removed. Installing again.

    #Gets the server host name
    $serverHostname =  Invoke-Command -ScriptBlock {hostname}

    # Creates Zabbix DIR
    mkdir c:\zabbix

    # Downloads version specified above
    $ProgressPreference=’SilentlyContinue’ 
    Invoke-WebRequest "$versionssl" -outfile c:\zabbix\zabbix.zip

    # Unzip function
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    function Unzip
    {
        param([string]$zipfile, [string]$outpath)

        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
    }

    # Unzipping file to c:\zabbix
    Unzip "c:\Zabbix\zabbix.zip" "c:\zabbix"      

    # Sorts files in c:\zabbix
    Move-Item c:\zabbix\bin\zabbix_agentd.exe -Destination c:\zabbix

    # Sorts files in c:\zabbix
    Move-Item c:\zabbix\conf\zabbix_agentd.conf -Destination c:\zabbix

    # Replaces 127.0.0.1 with your Zabbix server IP in the config file
    # You need to change the ip address with your own in the beginning of the Function
    (Get-Content -Path c:\zabbix\zabbix_agentd.conf) | ForEach-Object {$_ -Replace '127.0.0.1', "$ServerProxyIP"} | Set-Content -Path c:\zabbix\zabbix_agentd.conf

    # Replaces hostname in the config file
    (Get-Content -Path c:\zabbix\zabbix_agentd.conf) | ForEach-Object {$_ -Replace 'Windows host', "$ServerHostname"} | Set-Content -Path c:\zabbix\zabbix_agentd.conf

     Attempts to install the agent with the config in c:\zabbix
    c:\zabbix\zabbix_agentd.exe --config c:\zabbix\zabbix_agentd.conf --install

    # Attempts to start the agent
    c:\zabbix\zabbix_agentd.exe --start

    # Creates a firewall rule for the Zabbix server
    New-NetFirewallRule -DisplayName "Allow Zabbix communication" -Direction Inbound -Program "c:\zabbix\zabbix_agentd.exe" -RemoteAddress LocalSubnet -Action Allow

    }

}


else
{

# Gets hostname
$serverHostname =  Invoke-Command -ScriptBlock {hostname}
Write-host "Zabbix not found on " $serverHostname  "Beginning installation!" -ForegroundColor Red


#Gets the server host name
$serverHostname =  Invoke-Command -ScriptBlock {hostname}

# Creates Zabbix DIR
mkdir c:\zabbix

# Downloads version specified above
$ProgressPreference=’SilentlyContinue’ 
Invoke-WebRequest "$versionssl" -outfile c:\zabbix\zabbix.zip

# Unzip function
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

# Unzipping file to c:\zabbix
Unzip "c:\Zabbix\zabbix.zip" "c:\zabbix"      

# Sorts files in c:\zabbix
Move-Item c:\zabbix\bin\zabbix_agentd.exe -Destination c:\zabbix

# Sorts files in c:\zabbix
Move-Item c:\zabbix\conf\zabbix_agentd.conf -Destination c:\zabbix

# Replaces 127.0.0.1 with your Zabbix server IP in the config file
# You need to change the ip address with your own in the beginning of the Function
(Get-Content -Path c:\zabbix\zabbix_agentd.conf) | ForEach-Object {$_ -Replace '127.0.0.1', "$ServerProxyIP"} | Set-Content -Path c:\zabbix\zabbix_agentd.conf

# Replaces hostname in the config file
(Get-Content -Path c:\zabbix\zabbix_agentd.conf) | ForEach-Object {$_ -Replace 'Windows host', "$ServerHostname"} | Set-Content -Path c:\zabbix\zabbix_agentd.conf

# Attempts to install the agent with the config in c:\zabbix
c:\zabbix\zabbix_agentd.exe --config c:\zabbix\zabbix_agentd.conf --install

# Attempts to start the agent
c:\zabbix\zabbix_agentd.exe --start

# Creates a firewall rule for the Zabbix server
New-NetFirewallRule -DisplayName "Allow Zabbix communication" -Direction Inbound -Program "c:\zabbix\zabbix_agentd.exe" -RemoteAddress LocalSubnet -Action Allow

    }
}
# Function ZabbixInstallAD ends


# Finds all machines in a specific OU
$GetADMachines = Get-ADComputer -properties * -Filter * -SearchBase "OU=WindowsMachines,DC=twikki,DC=dk" | Select-Object Name

# Username and Password used for Windows Authentication
# You can also replace with your own credentials
# $Username = admtwikki
# $Password = xx

$Username = Read-Host 'What is your domain admin login?'
$Password = Read-Host 'What is your password?'
$SecurePassword = ConvertTo-SecureString -String $Password -asPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($Username,$SecurePassword)



ForEach ($Server in $GetADMachines) 
{
    Invoke-Command -ComputerName $Server.Name ` -ScriptBlock ${Function:InstallZabbixAD} ` -credential $Credential
}
Write-Host "Installation has been completed!" -ForegroundColor Green
Read-Host "Press any key to exit..."