#
# THIS SCRIPT IS READY TO USE
#

# Uninstalls Zabbix agent V2 on Windows
# Tested on Windows 10
# Version 1.00
# Created by Twikki
# Last updated 13/01/2021


# Attempts to stop the Zabbix service on the Windows machine
c:\zabbix\bin\zabbix_agent2.exe --stop --config c:\zabbix\conf\zabbix_agent2.conf

Write-Host zabbix_agentd has been stopped

# Attempts to uninstall the Zabbix agent on the Windows machine
c:\zabbix\bin\zabbix_agent2.exe --uninstall --config c:\zabbix\conf\zabbix_agent2.conf

Write-Host zabbix_agentd has been uninstalled

Start-Sleep -s 1

# Cleans up in c:\
Remove-Item c:\zabbix -Force -Recurse

# Cleans up logs in c:\
Remove-Item c:\zabbix_agent2.log

# Deletes the Zabbix firewall rule
Remove-NetFirewallRule -DisplayName "Allow Zabbix communication"
