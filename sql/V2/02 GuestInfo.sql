SET NOCOUNT ON
GO
DROP PROCEDURE IF EXISTS [ExportGuestInfo]
DROP VIEW IF EXISTS [GuestInfo]
GO
CREATE VIEW [GuestInfo]
WITH SCHEMABINDING
AS
SELECT TOP 100 PERCENT
	[GuestId] = g.[Id],
	[Staff] = g.[Staff],
	[FullName] = g.[FullName],
	[TicketId] = w.[Ticket_number],
	[TicketType] = COALESCE(w.[Ticket_type], N'CONCESSION: ' + gs.[Description]),
	[RoomType] = rt.[Description],
	[RoomTypeOk] = CONVERT(BIT, CASE
			WHEN r.[Confirmed] = 1 THEN 1
			WHEN g.[Staff] = 1 AND rt.[Description] = N'Standard Room' THEN 1
			WHEN g.[Staff] = 1 AND rt.[Description] != N'Standard Room' THEN NULL
			WHEN g.[Staff] = 0 AND w.[Ticket_type] LIKE N'SINGLE ROOM: %' AND rt.[Description] = N'Single Room' THEN 1
			WHEN g.[Staff] = 0 AND w.[Ticket_type] LIKE N'STANDARD ROOM: %' AND rt.[Description] = N'Standard Room' THEN 1
			WHEN g.[Staff] = 0 AND w.[Ticket_type] LIKE N'PREMIUM SUITE: %' AND rt.[Description] = N'Premium Suite with Jacuzzi' THEN 1
			ELSE 0
		END),
	[RoomConfig] = rc.[Description],
	[RoomConfigOk] = CONVERT(BIT, ISNULL(CASE rc.[Description] WHEN N'2 Single Beds' THEN 1 WHEN N'1 Double Bed' THEN CASE
			WHEN r.[Confirmed] = 1 THEN 1
			WHEN rt.[Description] = N'Single Room' THEN 1
			ELSE CASE
					WHEN r.[Staff] = 1 THEN 1
					WHEN w.[Sharing_info_1] LIKE N'%double%' THEN 1
					WHEN w.[Sharing_info_2] LIKE N'%double%' THEN 1
				END
		END END, 0)),
	[Reservation] = rs.[Description],
	[ReservationOk] = CONVERT(BIT, CASE
			WHEN gs.[Description] = rs.[Description] THEN 1
			WHEN g2s.[Description] = rs.[Description] THEN NULL
			ELSE 0
		END),
	[CheckInDate] = g.[CheckInDate],
	[FlightInTime] = g.[FlightInTime],
	[CheckOutDate] = g.[CheckOutDate],
	[FlightOutTime] = g.[FlightOutTime],
	[SharingWith] = g2.[FullName],
	[SharingWithId] = g2.[Id],
	[SharingWithOk] = CONVERT(BIT, CASE	WHEN rt.[Description] != N'Single Room' AND r.[GuestId2] IS NULL AND r.[Confirmed] = 0 THEN 0 ELSE 1 END),
	[DietaryInfo] = g.[DietaryInfo],
	[DietaryInfoOk] = CONVERT(BIT, CASE
			WHEN g.[DietaryInfo] IS NULL THEN 1
			WHEN g.[DietaryInfo] = w.[Dietary_info] THEN 1
			WHEN CHARINDEX(REPLACE(g.[DietaryInfo], N'&', N'and'), w.[Sharing_info_1]) > 0 THEN 1
			WHEN CHARINDEX(REPLACE(g.[DietaryInfo], N'&', N'and'), w.[Sharing_info_2]) > 0 THEN 1
			ELSE NULL
		END),
	[Confirmed] = r.[Confirmed]
FROM [dbo].[Guest] g
	JOIN [dbo].[Stay] gs ON g.[CheckInDate] = gs.[CheckInDate] AND g.[CheckOutDate] = gs.[CheckOutDate]
	JOIN [dbo].[Rooms] r ON g.[Id] IN (r.[GuestId1], r.[GuestId2])
	JOIN [dbo].[RoomType] rt ON r.[RoomTypeId] = rt.[Id]
	JOIN [dbo].[RoomConfig] rc ON r.[RoomConfigId] = rc.[Id]
	JOIN [dbo].[Stay] rs ON r.[CheckInDate] = rs.[CheckInDate] AND r.[CheckOutDate] = rs.[CheckOutDate]
	LEFT JOIN [dbo].[WebSales] w ON g.[TicketId] = w.[Ticket_number]
	LEFT JOIN [dbo].[Guest] g2 ON g2.[Id] IN (r.[GuestId1], r.[GuestId2]) AND g2.[Id] != g.[Id]
	LEFT JOIN [dbo].[Stay] g2s ON g2.[CheckInDate] = g2s.[CheckInDate] AND g2.[CheckOutDate] = g2s.[CheckOutDate]
	LEFT JOIN [dbo].[WebSales] w2 ON g2.[TicketId] = w2.[Ticket_number]
ORDER BY g.[FullName]
GO
CREATE PROCEDURE [ExportGuestInfo]
AS
BEGIN
	SET NOCOUNT ON
	SELECT (
			SELECT *,
				[HasQuestion] = CONVERT(BIT, CASE WHEN [RoomTypeOk] & [RoomConfigOk] & [ReservationOk] & [SharingWithOk] & [DietaryInfoOk] IS NULL THEN 1 ELSE 0 END),
				[HasProblem] = CONVERT(BIT, CASE
						WHEN [RoomTypeOk] = 0 THEN 1
						WHEN [RoomConfigOk] = 0 THEN 1
						WHEN [ReservationOk] = 0 THEN 1
						WHEN [SharingWithOk] = 0 THEN 1
						WHEN [DietaryInfoOk] = 0 THEN 1
						ELSE 0
					END)
			FROM [GuestInfo]
				CROSS APPLY (VALUES ([RoomTypeOk] & [RoomConfigOk] & [ReservationOk] & [SharingWithOk] & [DietaryInfoOk])) ok ([Ok])
			ORDER BY [FullName]
			FOR JSON PATH
		)
	RETURN
END
GO
SELECT* FROM [GuestInfo]