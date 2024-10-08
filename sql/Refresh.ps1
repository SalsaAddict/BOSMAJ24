Clear-Host
Set-Location $PSScriptRoot
Set-PSDebug -Strict
Set-StrictMode -Version Latest

$Server = 'fred.whitespace.co.uk,15002'
$Database = 'Advent_PAH'
$ServerTempPath = '\\fred.whitespace.co.uk\D$\tmp'

Import-Excel "websales.xlsx" -StartRow 3 -NoHeader | Export-Csv "websales.csv" -NoTypeInformation -Encoding unicode
Import-Excel "staging.xlsx" -AsText CheckInDate, FlightInTime, CheckOutDate, FlightOutTime | Export-Csv "staging.csv" -NoTypeInformation -Encoding unicode
Import-Excel "match.xlsx" | Export-Csv "match.csv" -NoTypeInformation -Encoding unicode

Copy-Item "websales.csv" $ServerTempPath
Copy-Item "staging.csv" $ServerTempPath
Copy-Item "match.csv" $ServerTempPath

Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query "EXEC [Import]" -T

Join-Path $ServerTempPath 'websales.csv' | Remove-Item
Join-Path $ServerTempPath 'staging.csv' | Remove-Item
Join-Path $ServerTempPath 'match.csv' | Remove-Item

Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query "EXEC [Allocate]" -T

sqlcmd -S $Server -d $Database -E -C -Q "EXEC [ExportHotelInfo]" -y 0 -o "hotelinfo.json" -f 65001
sqlcmd -S $Server -d $Database -E -C -Q "EXEC [ExportGuestInfo]" -y 0 -o "guestinfo.json" -f 65001

node encrypt.js