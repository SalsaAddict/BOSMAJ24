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
Import-Excel "act.xlsx" | Export-Csv "act.csv" -NoTypeInformation -Encoding unicode
Import-Excel "workshop.xlsx" -AsText Date | Export-Csv "workshop.csv" -NoTypeInformation -Encoding unicode

Copy-Item "websales.csv" $ServerTempPath
Copy-Item "staging.csv" $ServerTempPath
Copy-Item "match.csv" $ServerTempPath
Copy-Item "act.csv" $ServerTempPath
Copy-Item "workshop.csv" $ServerTempPath

Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query "EXEC [Import]" -T

Join-Path $ServerTempPath 'websales.csv' | Remove-Item
Join-Path $ServerTempPath 'staging.csv' | Remove-Item
Join-Path $ServerTempPath 'match.csv' | Remove-Item
Join-Path $ServerTempPath 'act.csv' | Remove-Item
Join-Path $ServerTempPath 'workshop.csv' | Remove-Item

Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query "EXEC [Allocate]" -T

sqlcmd -S $Server -d $Database -E -C -Q "EXEC [ExportHotelInfo]" -y 0 -o "hotelinfo.json" -f 65001
sqlcmd -S $Server -d $Database -E -C -Q "EXEC [ExportGuestInfo]" -y 0 -o "guestinfo.json" -f 65001
sqlcmd -S $Server -d $Database -E -C -Q "EXEC [ExportTimetable]" -y 0 -o "timetable.json" -f 65001
sqlcmd -S $Server -d $Database -E -C -Q "EXEC [ExportTeachers]" -y 0 -o "teachers.json" -f 65001

node encrypt.js