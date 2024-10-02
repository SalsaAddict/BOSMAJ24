SELECT
	s.[Order_number],
	s.[Ticket_number],
	s.[Ticket_type],
	s.[Guest_name],
	s.[Coupon],
	s.[Someone_to_share_with],
	s.[Sharing_info_1],
	s.[Sharing_info_2]
FROM [Guest] g
	JOIN [WebSales] s ON g.[TicketId] = s.[Ticket_number]
WHERE [Id] NOT IN (
		SELECT [GuestId1] FROM [Room] UNION
		SELECT [GuestId2] FROM [Room] WHERE [GuestId2] IS NOT NULL
	)
ORDER BY s.[Coupon], s.[Guest_name]

--SELECT * FROM WebSales WHERE [Guest_name] LIKE N'%lola%'
--SELECT * FROM WebSales WHERE [Order_number] = N'2WQD-JT1M-34G'