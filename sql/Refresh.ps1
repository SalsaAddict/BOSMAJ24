.\Import.ps1
Invoke-Sqlcmd -ServerInstance "fred.whitespace.co.uk,15002" -Database "Advent_PAH" -Query "EXEC [Allocate]" -T
.\Export.ps1