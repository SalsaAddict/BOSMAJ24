Clear-Host
Set-Location $PSScriptRoot
Set-PSDebug -Strict
Set-StrictMode -Version Latest

$Server = 'fred.whitespace.co.uk,15002'
$Database = 'Advent_PAH'

$Kill = @"
DECLARE @Command NVARCHAR(max)
SELECT @Command = ISNULL(@Command + N'; ', N'') + N'kill ' + CONVERT(NVARCHAR(10), [spid])
FROM [master].[dbo].[sysprocesses]
WHERE [dbid] = DB_ID(N'$Database')
EXEC sp_executesql @Command
"@

Invoke-Sqlcmd -ServerInstance $Server -Database "master" -Query $Kill -T
Invoke-Sqlcmd -ServerInstance $Server -Database "master" -Query "DROP DATABASE IF EXISTS [$Database]" -T
Invoke-Sqlcmd -ServerInstance $Server -Database "master" -Query "CREATE DATABASE [$Database]" -T
Invoke-Sqlcmd -ServerInstance $Server -Database $Database -InputFile '01 Objects.sql' -T
Invoke-Sqlcmd -ServerInstance $Server -Database $Database -InputFile '02 GuestInfo.sql' -T
Invoke-Sqlcmd -ServerInstance $Server -Database $Database -InputFile '03 Allocate.sql' -T
Invoke-Sqlcmd -ServerInstance $Server -Database $Database -InputFile '04 Export.sql' -T
Invoke-Sqlcmd -ServerInstance $Server -Database $Database -InputFile '05 Timetable.sql' -T

cd..
.\Refresh.ps1