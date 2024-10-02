Remove-Item "finance.csv"
Remove-Item "finance.xlsx"

Invoke-Sqlcmd -ServerInstance "fred.whitespace.co.uk,15002" -Database "Advent_PAH" -Query "SELECT * FROM [Finance]" -T | `Export-Csv "finance.csv" -NoTypeInformation

$Totals = @{
    "Total Guests"               = "Sum"
    "Total Rooms"                = "Sum"
    "Price Per Person Per Night" = "Sum"
    "Price Per Night"            = "Sum"
    "Price Per Stay"             = "Sum"
    "Total Price"                = "Sum"
    "Web Sales Revenue"          = "Sum"
    "Profit"                     = "Sum"
}

Import-Csv "finance.csv" | Export-Excel "finance.xlsx" -Now -TableTotalSettings $Totals