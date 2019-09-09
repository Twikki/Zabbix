# Used for later
#$computerliste = Get-ADComputer -Properties operatingsystem  -Filter {(operatingsystem -like "* Server *") -and (enabled -eq $true)