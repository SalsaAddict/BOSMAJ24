SELECT
	g.[Id],
	s.[Order_number],
	s.[Ticket_number],
	s.[Ticket_type],
	g.[FullName],
	s.[Coupon],
	s.[Someone_to_share_with],
	s.[Sharing_info_1],
	s.[Sharing_info_2]
FROM [Advent_PAH]..[Guest] g
	LEFT JOIN [Advent_PAH]..[WebSales] s ON g.[TicketId] = s.[Ticket_number]
WHERE [Id] NOT IN (
		SELECT [GuestId1] FROM [Advent_PAH]..[Room] UNION
		SELECT [GuestId2] FROM [Advent_PAH]..[Room] WHERE [GuestId2] IS NOT NULL
	)
ORDER BY s.[Coupon], g.[FullName]
