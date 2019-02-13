# Uninstall Zabbix agent on Windows
# Tested on Windows Server 2016, Virtual Machine
# Version 1.0
# Created by Daniel Jean Schmidt
# Last updated 13/02/2019
# Installs Zabbix Agent 4.0.4


# Attempts to stop the Zabbix service on the Windows machine
C:\Zabbix\zabbix_agentd.exe --stop

Write-Host zabbix_agentd has been stopped

# Attempts to uninstall the Zabbix agent on the Windows machine
C:\Zabbix\zabbix_agentd.exe --uninstall

WRite-Host zabbix_agentd h as been uninstalled

# Cleans up in C:\
Remove-Item C:\Zabbix -Force -Recurse

# Cleans up logs in C:\
Remove-Item C:\zabbix_agentd.log

# Deletes the Zabbix firewall rule
Remove-NetFirewallRule -DisplayName "Allow Zabbix communication"