

SELECT
	[Order_number] = s.[Order_number],
	[TicketId] = g.[TicketId],
	[GuestFullName] = g.[FullName],
	[TicketType] = s.[Ticket_type],
	[Room] = rt.[Description],
	[Config] = rc.[Description],
	[SingleOccupant] = CONVERT(BIT, CASE WHEN r.[GuestId2] IS NULL THEN 1 ELSE 0 END),
	[SharingWith] = shr.[FullName],
	[SomeoneToShareWith] = s.[Someone_to_share_with],
	[SharingInfo1] = s.[Sharing_info_1],
	[SharingInfo2] = s.[Sharing_info_2]
FROM [Room] r
	JOIN [RoomType] rt ON r.[RoomTypeId] = rt.[Id]
	JOIN [RoomConfig] rc ON r.[RoomConfigId] = rc.[Id]
	JOIN [Guest] g ON g.[Id] IN (r.[GuestId1], r.[GuestId2])
	LEFT JOIN [WebSales] s ON g.[TicketId] = s.[Ticket_number]
	LEFT JOIN [Guest] shr ON shr.[Id] IN (r.[GuestId1], r.[GuestId2]) AND shr.[Id] != g.[Id]
ORDER BY g.[IsStaff] DESC, g.[FullName]

SELECT * FROM [Room] WHERE [RoomTypeId] = N'J'