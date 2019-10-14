#
# THIS SCRIPT IS READY TO USE
#

# Uninstall Zabbix agent on Windows
# Tested on Windows Server 2016, Virtual Machine
# Version 1.01
# Created by Twikki
# Last updated 28/02/2019
# Installs Zabbix Agent 4.0.4


# Attempts to stop the Zabbix service on the Windows machine
c:\zabbix\zabbix_agentd.exe --stop

Write-Host zabbix_agentd has been stopped

# Attempts to uninstall the Zabbix agent on the Windows machine
c:\zabbix\zabbix_agentd.exe --uninstall

Write-Host zabbix_agentd has been uninstalled

# Cleans up in c:\
Remove-Item c:\zabbix -Force -Recurse

# Cleans up logs in c:\
Remove-Item c:\zabbix_agentd.log

# Deletes the Zabbix firewall rule
Remove-NetFirewallRule -DisplayName "Allow Zabbix communication"
