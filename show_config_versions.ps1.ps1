# Version: 1.0
# This file is maintained in Github

#
# THIS SCRIPT IS READY TO USE
#

# Configs

# Checks if zabbix_agentd.userparams.conf file exists. If yes, get's the version 
$ChkFile = "C:\Zabbix\conf\zabbix_agentd.userparams.conf"
$FileExists = Test-Path $ChkFile
If ($FileExists -eq $True) {

   Write-Host "zabbix_agentd.userparams.conf"
get-content c:\zabbix\conf\zabbix_agentd.userparams.conf | select -first 1

}


# Checks if zabbix_agentd.metadata.conf file exists. If yes, get's the version 
$ChkFile = "C:\Zabbix\conf\zabbix_agentd.metadata.conf"
$FileExists = Test-Path $ChkFile
If ($FileExists -eq $True) {

   Write-Host "zabbix_agentd.metadata.conf"
get-content c:\zabbix\conf\zabbix_agentd.metadata.conf | select -first 1

}

# Checks if zabbix_agentd.win.conf file exists. If yes, get's the version 
$ChkFile = "C:\Zabbix\zabbix_agentd.win.conf"
$FileExists = Test-Path $ChkFile
If ($FileExists -eq $True) {

   Write-Host "zabbix_agentd.win.conf"
get-content c:\zabbix\zabbix_agentd.win.conf | select -first 1

}


# SCRIPTS

# Checks if show_config_versions.ps1 file exists. If yes, get's the version 
$ChkFile = "C:\Zabbix\scripts\show_config_versions.ps1"
$FileExists = Test-Path $ChkFile
If ($FileExists -eq $True) {

   Write-Host "show_config_versions.ps1"
get-content C:\Zabbix\scripts\show_config_versions.ps1 | select -first 1

}