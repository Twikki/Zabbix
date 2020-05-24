#
# NOT READY YET
#


# Short description of script
# THIS IS USED FOR PUSHING ZABBIX AGENTS TO REMOTE IP ADDRESSES
# Installs the Zabbix agent if not installed, maintains the agent if installed, or updates the agent if not up to date.
# This script will be using private Github repositories for maintaining the files




# Username and Password used for Windows Authentication
$Username = Read-Host 'What is your domain + Username?'
$Password = Read-Host 'What is your password?'
$SecurePassword = ConvertTo-SecureString -String $Password -asPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($Username,$SecurePassword)

$Url = "https://www.zabbix.com/downloads/5.0.0/zabbix_agent-5.0.0-windows-amd64-openssl.zip"


function Choice1

{



#Gets the server host name
$serverHostname =  Invoke-Command -ScriptBlock {hostname}


# Asks the user for the IP address of their Zabbix server
$ServerIP = Read-Host -Prompt 'What is your Zabbix server/proxy IP?'


# Creates Zabbix DIR
mkdir c:\zabbix


# Downloads version 5.0.0 from https://www.zabbix.com/download_agents
Invoke-WebRequest $url -outfile c:\zabbix\zabbix.zip

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
(Get-Content -Path c:\zabbix\zabbix_agentd.conf) | ForEach-Object {$_ -Replace '127.0.0.1', "$ServerIP"} | Set-Content -Path c:\zabbix\zabbix_agentd.conf

# Replaces hostname in the config file
(Get-Content -Path c:\zabbix\zabbix_agentd.conf) | ForEach-Object {$_ -Replace 'Windows host', "$ServerHostname"} | Set-Content -Path c:\zabbix\zabbix_agentd.conf

# Attempts to install the agent with the config in c:\zabbix
c:\zabbix\zabbix_agentd.exe --config c:\zabbix\zabbix_agentd.conf --install

# Attempts to start the agent
c:\zabbix\zabbix_agentd.exe --start

# Creates a firewall rule for the Zabbix server
New-NetFirewallRule -DisplayName "Allow Zabbix communication" -Direction Inbound -Program "c:\zabbix\zabbix_agentd.exe" -RemoteAddress LocalSubnet -Action Allow

}


function Choice2

{



#Gets the server host name
$serverHostname =  Invoke-Command -ScriptBlock {hostname}



# Creates Zabbix DIR
mkdir c:\zabbix


# Downloads version 4.2.6 from https://www.zabbix.com/download_agents
Invoke-WebRequest $url -outfile c:\zabbix\zabbix.zip

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
(Get-Content -Path c:\zabbix\zabbix_agentd.conf) | ForEach-Object {$_ -Replace '127.0.0.1', "$ServerIP"} | Set-Content -Path c:\zabbix\zabbix_agentd.conf

# Replaces hostname in the config file
(Get-Content -Path c:\zabbix\zabbix_agentd.conf) | ForEach-Object {$_ -Replace 'Windows host', "$ServerHostname"} | Set-Content -Path c:\zabbix\zabbix_agentd.conf

# Attempts to install the agent with the config in c:\zabbix
c:\zabbix\zabbix_agentd.exe --config c:\zabbix\zabbix_agentd.conf --install

# Attempts to start the agent
c:\zabbix\zabbix_agentd.exe --start

# Creates a firewall rule for the Zabbix server
New-NetFirewallRule -DisplayName "Allow Zabbix communication" -Direction Inbound -Program "c:\zabbix\zabbix_agentd.exe" -RemoteAddress LocalSubnet -Action Allow

}

















# Make a Menu for choices

Write-Host 'Please choose what you would like to do with Zabbix :)' -ForegroundColor Green

Write-Host '1. I want to install Zabbix agent on a remote server'
Write-Host '2. I want to install Zabbix agent(s) on remote servers from a predefined CSV file with predefined ip addresses'
Write-Host '3. I want to install Zabbix agent(s) on remote servers from a predefined TXT file with predefined ip addresses'
Write-Host '4. I want to update zabbix agent on a remote server'
Write-Host '5. I want to update my Zabbix agent(s) on remote servers from a predefined CSV file with predefined ip addresses'
Write-Host '6. I want to update my Zabbix agent(s) on remote servers from a predefined TXT file with predefined ip addresses'
$MenuChoice = Read-Host 'Please choose an operation'




If ($MenuChoice -eq 1) 
{
    # Installs Zabbix agent on a remote server
    $Server = Read-Host -Prompt 'Please enter the ip address or DNS name of the server you wish to install Zabbix Agent on'
    Invoke-Command -ComputerName $Server ` -ScriptBlock ${Function:Choice1} ` -credential $Credential

}
elseif ($MenuChoice -eq 2)
{

    $ServerIP
    
If (!$ServerIP)

    {
    Write-Host "You have not yet defined your Server Proxy IP" -ForegroundColor Cyan -BackgroundColor Black
    # Asks the user for the IP address of their Zabbix server
    $ServerIP = Read-Host -Prompt 'What is your Zabbix server/proxy IP?';
    }




    # Ask the user where the file is
    $IPList = Read-Host -Prompt 'Please Specify where the list is located'

    # Runs through the list 
    foreach($line in Get-Content $IPList) {
        if($line -match $regex){
            
        # Installs Zabbix agent on a remote server
        Invoke-Command -ComputerName $Server$IPList ` -ScriptBlock ${Function:Choice2} ` -credential $Credential

        }
    }




}
elseif ($MenuChoice -eq 3) 
{
    
}
elseif ($MenuChoice -eq 4) 
{
    
}
elseif ($MenuChoice -eq 5) 
{
    
}
elseif ($MenuChoice -eq 6) 
{
    
}