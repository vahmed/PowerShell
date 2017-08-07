<# 
Oracle Managed DAO Example
#>

Add-Type -Path "C:\app\oracle\product\12.1.0\client_1\ODP.NET\managed\common\Oracle.ManagedDataAccess.dll"
#[System.Reflection.Assembly]::UnsafeLoadFrom("..\OneSourceProvision.v11.Admin.dll") | Out-Null

$username = Read-Host -Prompt "Enter database username"
$password = Read-Host -Prompt "Enter database password"
$datasource = Read-Host -Prompt "Enter database TNS name"
$query = "select * from dual"
$connectionString = 'User Id=' + $username + ';Password=' + $password + ';Data Source=' + $datasource
$connection = New-Object Oracle.ManagedDataAccess.Client.OracleConnection($connectionString)
$connection.open()
$command=$connection.CreateCommand()
$command.CommandText=$query
$reader=$command.ExecuteReader()
while ($reader.Read()) {
#$reader.GetString(1) + ', ' + $reader.GetString(0)
$reader.GetString(0)
}
$connection.Close()
