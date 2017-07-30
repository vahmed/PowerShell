# Setup Variables
$Total = 0
$InUse = 0
$StrHost = "Localhost" 

# Get Citrix licensing Info
$licensePool = gwmi -class "Citrix_GT_License_Pool" -Namespace "Root\CitrixLicensing" -comp $StrHost

$LicensePool | ForEach-Object{ If ($_.PLD -eq "MPS_ADV_CCU"){
    $Total = $Total + $_.Count
    $InUse = $InUse + $_.InUseCount
    }
}

$PercentUsed = [Math]::Round($inuse/$total*100,0)
$Free = [Math]::Round($Total-$Inuse)

echo "Total: ",$Total
echo "In Use: ",$InUse
echo "Free: ",$Free
echo "Percent Used: ", $PercentUsed
