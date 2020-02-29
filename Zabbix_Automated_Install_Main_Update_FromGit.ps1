[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$GithubToken = "68a9419cf9050cc45b5c9b766da2818090d20a43"

$Script = Invoke-RestMethod https://api.github.com/repos/Twikki/youtubetest/contents/Zabbix_Automated_Install_Main_Update_FromGit.ps1?access_token=$GithubToken -Headers @{”Accept”= “application/vnd.github.v3.raw”}

Invoke-Expression $Script