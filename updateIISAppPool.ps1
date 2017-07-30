<################################################################################
 updateIISAppPool.ps1
 Created/Modified: 05-Aug-2015
 Description: Updates AppPool's recycle time
 Notes: 
#################################################################################>

If ((Test-Path .\output.txt))
{
    $ErrorActionPreference="SilentlyContinue"
    Stop-Transcript | Out-Null
    Remove-Item .\output.txt -Recurse -Force
}

Start-Transcript -path output.txt -append

Write-Host -ForegroundColor Green "********************|Update IIS Properties Begin|********************" | Out-Host

$Pol="RemoteSigned"
$ExecPol=(Get-ExecutionPolicy)
If (-not($ExecPol -match $Pol))
 {
    Write-Host -ForegroundColor Red "Execution policy needs to be RemoteSigned. Please run 'Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force' then re-run this script" | Out-Host
    exit
 }

function validateCreds
{
  Param ($creds)
  $username = $creds.username
  $password = $creds.GetNetworkCredential().password
  $domain = "LDAP://" + ([ADSI]"").distinguishedName
  $authentication = New-Object System.DirectoryServices.DirectoryEntry($domain,$username,$password)
  if ($authentication.name -eq $null) { return $false; } `
  else { return $true; }
}

$SMTPServer = "relay"
$creds = $Host.ui.PromptForCredential("Need credentials","Enter your Credentials","$env:Userdomain\$env:Username","")
$pass = $creds.GetNetworkCredential().Password
$From = "installAdmin@sample.com"
$To =  @("devops@sample.com","notify2@sample.com")
$Attachment = ".\output.txt"
$Subject = "Update IIS Properties"
$Body = "Updating IIS Properties Complete. Please review attached log"

if(!(validateCreds($creds))) {
  $wshell = New-Object -ComObject Wscript.Shell
  $wshell.Popup("ERROR: Please Check Your Credentials And Try Again.",0,"Authentication Failed!")
  exit
}

$scriptBlock = {
    Import-Module WebAdministration
    Get-ItemProperty "IIS:\Sites\Default Web Site\SampleWeb" -Name preloadEnabled
    Set-ItemProperty "IIS:\Sites\Default Web Site\SampleWeb" -name preloadEnabled -value True
    Get-ItemProperty "IIS:\Sites\Default Web Site\SampleWeb" -Name preloadEnabled
 }

Invoke-Command -ComputerName web1,web2 -ScriptBlock $scriptBlock -Credential $creds | Out-Host

Write-Host -ForegroundColor Green "********************|Update IIS Properties End|********************" | Out-Host

Stop-Transcript
Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -Attachments $Attachment
