Clear-Host
Set-Location $PSScriptRoot
Set-PSDebug -Strict
Set-StrictMode -Version Latest

$Server = 'fred.whitespace.co.uk,15002'
$Database = 'Advent_PAH'

Invoke-Sqlcmd -ServerInstance $Server -Database "master" -Query "DROP DATABASE IF EXISTS [$Database]" -T
Invoke-Sqlcmd -ServerInstance $Server -Database "master" -Query "CREATE DATABASE [$Database]" -T
Invoke-Sqlcmd -ServerInstance $Server -Database $Database -InputFile '01 Objects.sql' -T
Invoke-Sqlcmd -ServerInstance $Server -Database $Database -InputFile '02 GuestInfo.sql' -T
Invoke-Sqlcmd -ServerInstance $Server -Database $Database -InputFile '03 Allocate.sql' -T
Invoke-Sqlcmd -ServerInstance $Server -Database $Database -InputFile '04 Export.sql' -T
