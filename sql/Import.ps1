Import-Excel "artists.xlsx" | Export-Csv "artists.csv" -NoTypeInformation -Encoding unicode
Import-Excel "websales.xlsx" -StartRow 3 -NoHeader | Export-Csv "websales.csv" -NoTypeInformation -Encoding unicode
Copy-Item "artists.csv" "\\fred.whitespace.co.uk\D$\tmp"
Copy-Item "websales.csv" "\\fred.whitespace.co.uk\D$\tmp"
Invoke-Sqlcmd -ServerInstance "fred.whitespace.co.uk,15002" -Database "Advent_PAH" -Query "EXEC [Import]" -T
Remove-Item "\\fred.whitespace.co.uk\D$\tmp\artists.csv"
Remove-Item "\\fred.whitespace.co.uk\D$\tmp\websales.csv"
