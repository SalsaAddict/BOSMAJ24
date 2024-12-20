SET NOCOUNT ON
GO
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
							[Configuration] = rc.[Description],
							[StaffThuMon] = COUNT(DISTINCT CASE WHEN r.[Staff] = 1 AND per.[Description] = N'Thu-Mon' THEN r.[RoomId] ELSE NULL END),
							[GuestsThuMon] = COUNT(DISTINCT CASE WHEN r.[Staff] = 0 AND per.[Description] = N'Thu-Mon' THEN r.[RoomId] ELSE NULL END),
							[StaffFriMon] = COUNT(DISTINCT CASE WHEN r.[Staff] = 1 AND per.[Description] = N'Fri-Mon' THEN r.[RoomId] ELSE NULL END),
							[GuestsFriMon] = COUNT(DISTINCT CASE WHEN r.[Staff] = 0 AND per.[Description] = N'Fri-Mon' THEN r.[RoomId] ELSE NULL END),
							[Total] = COUNT(DISTINCT r.[RoomId]),
							[Guests] = COUNT(DISTINCT g.[Id])
						FROM [Rooms] r
							JOIN [RoomType] rt ON r.[RoomTypeId] = rt.[Id]
							JOIN [RoomConfig] rc ON r.[RoomConfigId] = rc.[Id]
							JOIN [Stay] per ON r.[CheckInDate] = per.[CheckInDate] AND r.[CheckOutDate] = per.[CheckOutDate]
							JOIN [Guest] g ON g.[Id] IN (r.[GuestId1], r.[GuestId2])
						GROUP BY rt.[Sort], rt.[Description], rc.[Sort], rc.[Description]
						WITH ROLLUP
						HAVING GROUPING(rt.[Sort]) & GROUPING(rt.[Description]) & GROUPING(rc.[Sort]) & GROUPING(rc.[Description]) = 1
							OR GROUPING(rt.[Sort]) | GROUPING(rt.[Description]) | GROUPING(rc.[Sort]) | GROUPING(rc.[Description]) = 0
						ORDER BY GROUPING(rt.[Sort]), rt.[Sort], rc.[Sort]
						FOR JSON PATH
					),
				[Allocations] = (
						SELECT
							[GuestType] = [Description],
							[Stays] = (
									SELECT
										[Stay] = per.[Description],
										[Nights] = per.[Nights],
										[RoomTypes] = (
												SELECT
													[RoomType] = rt.[Description],
													[Configurations] = (
															SELECT
																[Configuration] = rc.[Description],
																[Rooms] = (
																		SELECT
																			[RoomId] = r.[RoomId],
																			[Occupants] = r.[Occupants],
																			[Guests] = (
																					SELECT
																						[Forename] = g.[Forename],
																						[Surname] = g.[Surname],
																						[Stay] = gs.[Description],
																						[StayOk] = CONVERT(BIT, CASE WHEN gs.[Description] = per.[Description] THEN 1 ELSE 0 END),
																						[DietaryInfo] = g.[DietaryInfo],
																						[Reference] = g.[TicketId],
																						[Staff] = g.[Staff]
																					FROM [Guest] g
																						JOIN [Stay] gs ON g.[CheckInDate] = gs.[CheckInDate] AND g.[CheckOutDate] = gs.[CheckOutDate]
																					WHERE g.[Id] IN (r.[GuestId1], r.[GuestId2])
																					FOR JSON PATH
																				)
																		FROM [Rooms] r
																		WHERE gt.[Staff] = r.[Staff]
																			AND r.[RoomTypeId] = rt.[Id]
																			AND r.[RoomConfigId] = rc.[Id]
																			AND r.[CheckInDate] = per.[CheckInDate]
																			AND r.[CheckOutDate] = per.[CheckOutDate]
																		ORDER BY r.[RoomId]
																		FOR JSON PATH
																	)
															FROM [RoomConfig] rc
															ORDER BY rc.[Sort]
															FOR JSON PATH
														)
												FROM [RoomType] rt
												ORDER BY rt.[Sort]
												FOR JSON PATH
											)
									FROM [Stay] per
									ORDER BY per.[CheckInDate], per.[CheckOutDate]
									FOR JSON PATH
								)
						FROM [GuestType] gt
						ORDER BY gt.[Staff] DESC
						FOR JSON PATH
					)
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		)
	RETURN
END
GO