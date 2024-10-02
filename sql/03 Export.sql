DROP PROCEDURE IF EXISTS [ExportHotelInfo]
GO
CREATE PROCEDURE [ExportHotelInfo]
AS
BEGIN
	SET NOCOUNT ON
	SELECT (
			SELECT
				[Summary] = (
						SELECT
							[RoomType] = rt.[Description],
							[Period] = a.[CheckInDay] + N'-' + a.[CheckOutDay],
							[Rooms] = COUNT(DISTINCT r.[Id]),
							[Guests] = COUNT(*)
						FROM [Occupant] o
							JOIN [Room] r ON o.[RoomId] = r.[Id]
							JOIN [RoomType] rt ON r.[RoomTypeId] = rt.[Id]
							JOIN [Attendee] a ON o.[OrderId] = a.[OrderId] AND o.[TicketId] = a.[TicketId]
						GROUP BY rt.[Description], a.[CheckInDay], a.[CheckOutDay] WITH ROLLUP
						HAVING (GROUPING(a.[CheckInDay]) | GROUPING(a.[CheckOutDay])) & ~GROUPING(rt.[Description]) = 0
						ORDER BY GROUPING(rt.[Description]), MIN(rt.[SortOrder]), a.[CheckInDay] DESC, a.[CheckOutDay]
						FOR JSON PATH
					),
				[Dietary] = (
						SELECT
							[Dietary],
							[Guests] = COUNT(*)
						FROM [Attendee]
						WHERE [Dietary] IS NOT NULL
						GROUP BY [Dietary]
						ORDER BY [Dietary]
						FOR JSON PATH
					),
				[RoomTypes] = (
						SELECT
							rt.[Description],
							[Rooms] = (
									SELECT
										[Guests] = (
												SELECT
													[Forename] = a.[Forename],
													[Surname] = a.[Surname],
													[Reference] = a.[TicketId],
													[CheckInDay] = a.[CheckInDay],
													[CheckOutDay] = a.[CheckOutDay],
													[Dietary] = a.[Dietary]
												FROM [Occupant] o
													JOIN [Attendee] a ON o.[OrderId] = a.[OrderId] AND o.[TicketId] = a.[TicketId]
												WHERE o.[RoomId] = r.[Id]
												ORDER BY o.[OccupantId]
												FOR JSON PATH
											),
										[Notes] = r.[Notes]
									FROM [Room] r
									WHERE r.[RoomTypeId] = rt.[Id]
									FOR JSON PATH
								)
						FROM [RoomType] rt
						ORDER BY rt.[SortOrder]
						FOR JSON PATH
					)
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		)
	RETURN
END
GO