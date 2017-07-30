<################################################################################
installOracleClient
 Created/Modified: 05-Aug-2015
 Description: Installs Oracle 11.2.0.4 Client
#################################################################################>
# --> This command --> "Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force" must be issued before launching this script

$From = "installAdmin@sample.com"
#$To = @("notify@sample.com")
$To = "notify@sample.com"
$Subject = "Oracle install Output"
$Attachment = "E:\temp\Build\Oracle_Install.zip"
$Body = "Please review the logs in the attached archive"
$SMTPServer = "relay"

If ((Test-Path output.txt))
{
	Remove-Item output.txt -Recurse -Force
}
$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path output.txt -append

If (-not(Test-Path E:\temp\Build\Install_Oracle*))
{
	Write-Host -ForegroundColor Red "Copy installOracleClient.ps1 in to E:\temp\Build and re-run"
	sleep 2
	$wshell = New-Object -ComObject Wscript.Shell
	$wshell.Popup("Copy installOracleClient.ps1 in to E:\temp\Build and re-run",0,"ERROR: Incorrect directory")
	Stop-Transcript
	Remove-Item output.txt -Recurse -Force
	exit
}

Function installOracle86()
{
	Write-Host -ForegroundColor Yellow "Checking if Oracle client x86 is installed"
	sleep 2
	If(-not(Test-Path 'C:\Program Files (x86)\Oracle'))
	{
	Write-Host -ForegroundColor Red "Oracle client x86 is NOT installed"
	sleep 2
	Write-Host -ForegroundColor Yellow "Extracting Oracle Client 32Bit"
	sleep 2
	Start-Process "E:\temp\Build\unzip.exe" -ArgumentList '-d','E:\temp\Build\Oracle_x86','E:\temp\Build\p10404530_112030_WINNT_3of6.zip' -Wait
	streamsFix
	$OraInstx86="E:\temp\Build\Oracle_x86\client\setup.exe" 
	$OraArgsx86="-silent -ignorePrereq -waitforcompletion -responseFile E:\temp\Build\client_install_x86.rsp" ###Other Options: -noconsole
	Write-Host -ForegroundColor Yellow "Installing Oracle Client 32Bit"
	sleep 2
	Start-Process $OraInstx86 -ArgumentList $OraArgsx86 -Wait
		If (Test-Path 'E:\Build\11.2.0.3\client_1\x86')
		{
		Write-Host -ForegroundColor Yellow "Oracle Client 32Bit installed successfully"
		sleep 2
		Copy-Item -Verbose 'E:\temp\Build\tnsnames.ora' 'E:\Oracle\11.2.0.3\client_1\x86\network\admin'
		}
	}
			Else 
			{ 
			Write-Host -ForegroundColor Yellow "Oracle client x86 has been detected as installed"
			sleep 2
			}
}

Function installOracle64()
{
	Write-Host -ForegroundColor Yellow "Checking if Oracle client x64 is installed"
	sleep 2
	If(-not(Test-Path 'C:\Program Files\Oracle'))
	{
	Write-Host -ForegroundColor Red "Oracle client x64 is NOT installed"
	sleep 2
	Write-Host -ForegroundColor Yellow "Extracting Oracle Client 64Bit"
	sleep 2
	Start-Process "E:\temp\Build\unzip.exe" -ArgumentList '-d','E:\temp\Build\Oracle_x64','E:\temp\Build\p10404530_112030_MSWIN-x86-64_4of7.zip' -Wait
	streamsFix
	$OraInstx64="E:\temp\Build\Oracle_x64\p10404530_112030_MSWIN-x86-64_4of7\client\setup.exe" 
	$OraArgsx64="-silent -ignorePrereq -waitforcompletion -responseFile E:\temp\Build\client_install_x64.rsp" ###Other Options: -noconsole
	Write-Host -ForegroundColor Yellow "Installing Oracle Client 64Bit"
	sleep 2
	Start-Process $OraInstx64 -ArgumentList $OraArgsx64 -Wait
		If (Test-Path 'E:\Build\11.2.0.3\client_2\x64')
		{
		Write-Host -ForegroundColor Yellow "Oracle Client 64Bit installed successfully"
		sleep 2
		Copy-Item -Verbose 'E:\temp\Build\tnsnames.ora' 'E:\Oracle\11.2.0.3\client_2\x64\network\admin'
		}
	}
			Else 
			{ 
			Write-Host -ForegroundColor Yellow "Oracle client x64 has been detected as installed"
			sleep 2
			}
}

installOracle64
installOracle86

Stop-Transcript
& "e:\temp\zip.exe" a -tzip -wE:\temp\Build Oracle_Install.zip *.log output.txt
Send-MailMessage -From $From -To $To -Subject $Subject -Attachments $Attachment -Body $Body -SmtpServer $SMTPServer
sleep 10
#shutdown -r -t 00 -f
