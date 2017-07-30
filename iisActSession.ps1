
$servers=@("web1","web2")

foreach ($server in $servers)
{
    	$activeSessions=$($(Get-Counter -ComputerName $server -Counter '\Web Service(_total)\Current Connections').countersamples).cookedvalue
        #Write-Host $server ":" $activeSessions
        $activeSessions += $activeSessions
}
(New-Object System.Net.WebClient).DownloadString("http://devops.sample.net/stats.php?active=$activeSessions")
