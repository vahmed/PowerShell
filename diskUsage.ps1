$DownloadDir = (Get-Item -Path ".\" -Verbose).FullName
$proxy = New-Object System.Net.WebProxy("http://webproxy:80")
$URLF = "http://devops.sample.com/servers.txt"
$GetFile = New-Object "System.Net.WebClient"
$GetFile.proxy = $proxy
$GetFile.DownloadFile($URLF, "$DownloadDir\servers.txt")
$servers = Get-Content .\prod_servers.txt
Foreach ($server in $servers) {

$url = "http://$server`:1055/sinfo?gr=-1"
[xml]$xml = (new-object System.Net.WebClient).DownloadString($url)
Write-Host -ForegroundColor Yellow $server

#$xml.windows.drives.drive[1..3] | Select-Object name,fs,desc, @{Name="Free Size(GB)";Expression={[math]::round($_.free / 1Gb,3)}}
#DH Added formatting for Free Size column

$xml.windows.drives.drive[1..3] | Select-Object name,fs,desc, @{Name="Free Size(GB)";Expression={[math]::round($_.free / 1Gb,3).ToString("#0.000").PadLeft(13)}}

}

