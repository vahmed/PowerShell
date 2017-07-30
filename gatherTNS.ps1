<################################################################################
 gatherTNS
 Created/Modified: 19-May-2016
 Description: Gathers $ORACLE_HOME from all Linux servers
#################################################################################>
If ((Test-Path .\output.txt))
{
    $ErrorActionPreference="SilentlyContinue"
    Stop-Transcript | Out-Null
    Remove-Item .\output.txt -Recurse -Force
}
Write-Host -ForegroundColor Green "********************|Gather ORACLE_HOME Begin|********************" | Out-Host

$Pol="RemoteSigned"
$ExecPol=(Get-ExecutionPolicy)
If (-not($ExecPol -match $Pol))
 {
    Write-Host -ForegroundColor Red "Execution policy needs to be RemoteSigned. Please run 'Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force' then re-run this script" | Out-Host
    exit
 }
 
$SMTPServer = "smtp"
$creds = $Host.ui.PromptForCredential("Need credentials","Enter Linux User Credentials","","")
$pass = $creds.GetNetworkCredential().Password
$From = "installAdmin@sample.com"
$To = "notify@sample.com"
$Attachment = ".\output.txt"
$Subject = "gatherORACLE_HOME Output"
$Body = "gatherORACLE_HOME Complete. Please review attached log"
Start-Transcript -path .\output.txt

Write-Host -ForegroundColor Red "Removing any old files" | Out-Host
Remove-Item .\servers.txt -ErrorAction SilentlyContinue | Out-Host
Remove-Item .\plink.exe -ErrorAction SilentlyContinue | Out-Host
Remove-Item .\pscp.exe -ErrorAction SilentlyContinue | Out-Host

$DownloadDir = (Get-Item -Path ".\" -Verbose).FullName
[Environment]::SetEnvironmentVariable("http_proxy", "http://webproxy:80")
$urls = @("http://repo.sample.com/servers.txt","http://repo.sample.com/pscp.exe","http://repo.sample.com/plink.exe")
foreach ($url in $urls) {
    .\wget.exe -t 3 --show-progress $url
}
Remove-Item Env:\http_proxy

$servernames = Get-Content .\servers.txt

foreach ($servername in $servernames) {

Write-Host -ForegroundColor Green "Checking $servername" | Out-Host

Echo Y | .\plink -l appserver -pw $pass $servername "cat .bashrc |grep ORACLE_HOME= | cut -d= -f2 | sed 's/$/\/network\/admin/'| xargs ls -l" | Out-Host

}

Write-Host -ForegroundColor Green "********************|Gather ORACLE_HOME End|********************" | Out-Host

Remove-Item .\servers.txt -Recurse | Out-Host
Stop-Transcript
Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -Attachments $Attachment
Remove-Item .\output.txt -Recurse -Force
