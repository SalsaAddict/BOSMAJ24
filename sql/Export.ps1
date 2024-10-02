sqlcmd -S "fred.whitespace.co.uk, 15002" -d Advent_PAH -E -C -Q "EXEC [ExportHotelInfo]" -y 0 -o "hotelinfo.json" -f 65001
sqlcmd -S "fred.whitespace.co.uk, 15002" -d Advent_PAH -E -C -Q "EXEC [ExportGuestInfo]" -y 0 -o "guestinfo.json" -f 65001
node encrypt.js