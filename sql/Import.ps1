Import-Excel "websales.xlsx" -StartRow 3 -NoHeader | Export-Csv "websales.csv" -NoTypeInformation -Encoding unicode
Import-Excel "concessions.xlsx" -AsText CheckInDate, CheckOutDate | Export-Csv "concessions.csv" -NoTypeInformation -Encoding unicode
Import-Excel "match.xlsx" | Export-Csv "match.csv" -NoTypeInformation -Encoding unicode
Copy-Item "websales.csv" "\\fred.whitespace.co.uk\D$\tmp"
Copy-Item "concessions.csv" "\\fred.whitespace.co.uk\D$\tmp"
Copy-Item "match.csv" "\\fred.whitespace.co.uk\D$\tmp"
Invoke-Sqlcmd -ServerInstance "fred.whitespace.co.uk,15002" -Database "Advent_PAH" -Query "EXEC [Import]" -T
Remove-Item "\\fred.whitespace.co.uk\D$\tmp\websales.csv"
Remove-Item "\\fred.whitespace.co.uk\D$\tmp\concessions.csv"
Remove-Item "\\fred.whitespace.co.uk\D$\tmp\match.csv"
