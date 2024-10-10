SET NOCOUNT ON
GO
DROP PROCEDURE IF EXISTS [Allocate]
GO
CREATE PROCEDURE [Allocate]
AS
BEGIN
	SET NOCOUNT ON

	DELETE [Room]
	DBCC CHECKIDENT ([Room], reseed, 1)
	DBCC CHECKIDENT ([Room], reseed)

	BEGIN TRY

		BEGIN TRANSACTION

			INSERT INTO [Room] (
				[RoomTypeId],
				[RoomConfigId],
				[GuestId1],
				[GuestId2],
				[Confirmed]
			)
			-- ***** SINGLE ROOMS *****
			SELECT
				[RoomTypeId] = N'U',
				[RoomConfigId] = N'D',
				[GuestId1] = g.[Id],
				[GuestId2] = NULL,
				[Confirmed] = CONVERT(BIT, 1)
			FROM [WebSalesTicketsPerOrder] c
				JOIN [WebSales] s ON c.[Order_number] = s.[Order_number]
				JOIN [Guest] g ON s.[Ticket_number] = g.[TicketId]
			WHERE c.[Ticket_type] LIKE N'SINGLE ROOM: %'
			-- ***** 2 GUESTS ON SAME BOOKING ****
			UNION ALL
			SELECT
				[RoomTypeId] = CASE
						WHEN c.[Ticket_type] LIKE N'STANDARD ROOM: %' THEN N'S'
						WHEN c.[Ticket_type] LIKE N'PREMIUM SUITE: %' THEN N'J'
					END,
				[RoomConfigId] = CASE WHEN c.[Order_number] IN (
						N'2W9B-V5NP-F7W',
						N'2WL0-M7NZ-S09'
					) THEN 'D' ELSE 'T' END,
				[GuestId1] = MIN(CASE WHEN os.[Order_sequence] = 1 THEN g.[Id] END),
				[GuestId2] = MIN(CASE WHEN os.[Order_sequence] = 2 THEN g.[Id] END),
				[Confirmed] = CONVERT(BIT, 1)
			FROM [WebSalesTicketsPerOrder] c
				JOIN [WebSalesOrderSequence] os ON c.[Order_number] = os.[Order_number]
				JOIN [Guest] g ON os.[Ticket_number] = g.[TicketId]
			WHERE c.[Ticket_count] = 2
				AND c.[Ticket_type] NOT LIKE N'SINGLE ROOM: %'
			GROUP BY c.[Order_number], c.[Ticket_type]
			-- ***** NAMED SHARING *****
			UNION ALL
			SELECT
				[RoomTypeId] = CASE
						WHEN s1.[Ticket_type] LIKE N'STANDARD ROOM: %' THEN N'S'
						WHEN s1.[Ticket_type] LIKE N'PREMIUM SUITE: %' THEN N'J'
					END,
				[RoomConfigId] = CASE WHEN s1.[Ticket_number] IN (
						N'2WNR-NWMH-J501P',
						N'2WL0-L6N3-SV71P'
					) THEN 'D' ELSE 'T' END,
				[GuestId1] = g1.[Id],
				[GuestId2] = g2.[Id],
				[Confirmed] = CONVERT(BIT, 1)
			FROM [WebSales] s1
				JOIN [Guest] g1 ON s1.[Ticket_number] = g1.[TicketId]
				JOIN [WebSales] s2 ON LEFT(s1.[Ticket_type], CHARINDEX(N':', s1.[Ticket_type])) = LEFT(s2.[Ticket_type], CHARINDEX(N':', s2.[Ticket_type]))
				JOIN [Guest] g2 ON s2.[Ticket_number] = g2.[TicketId]
			WHERE s1.[Ticket_type] NOT LIKE N'SINGLE ROOM: %'
				AND s1.[Order_number] < s2.[Order_number]
				AND s1.[Ticket_number] != s2.[Ticket_number]
				AND (
						TRIM(REPLACE(s2.[Sharing_info_1], N' ', N'')) LIKE N'%' + REPLACE(s1.[Guest_name], N' ', N'') + N'%'
						OR TRIM(REPLACE(s2.[Sharing_info_2], N' ', N'')) LIKE N'%' + REPLACE(s1.[Guest_name], N' ', N'') + N'%'
						OR TRIM(REPLACE(s1.[Sharing_info_1], N' ', N'')) LIKE N'%' + REPLACE(s2.[Guest_name], N' ', N'') + N'%'
						OR TRIM(REPLACE(s1.[Sharing_info_2], N' ', N'')) LIKE N'%' + REPLACE(s2.[Guest_name], N' ', N'') + N'%'
					)

			MERGE
			INTO [Room] tgt
			USING (
					SELECT
						[RoomTypeId] = m.[RoomTypeId],
						[RoomConfigId] = m.[RoomConfigId],
						[GuestId1] = g1.[Id],
						[GuestId2] = g2.[Id],
						[Confirmed] = m.[Confirmed]
					FROM [Match] m
						LEFT JOIN [Guest] g1 ON m.[Guest1] = g1.[FullName]
						LEFT JOIN [Guest] g2 ON m.[Guest2] = g2.[FullName]
				) src
			ON src.[GuestId1] = tgt.[GuestId1] AND ISNULL(src.[GuestId2], -1) = ISNULL(tgt.[GuestId2], -1)
			WHEN MATCHED THEN UPDATE SET
				[RoomTypeId] = src.[RoomTypeId],
				[RoomConfigId] = src.[RoomConfigId],
				[Confirmed] = src.[Confirmed]
			WHEN NOT MATCHED BY TARGET THEN
				INSERT ([RoomTypeId], [RoomConfigId], [GuestId1], [GuestId2], [Confirmed])
				VALUES (src.[RoomTypeId], src.[RoomConfigId], src.[GuestId1], src.[GuestId2], src.[Confirmed]);

			IF EXISTS (
				SELECT *
				FROM [Rooms] r
					LEFT JOIN [Stay] s ON r.[CheckInDate] = s.[CheckInDate]
						AND r.[CheckOutDate] = s.[CheckOutDate]
						AND s.[AllowReservation] = 1
				WHERE s.[Description] IS NULL
			) RAISERROR(N'Invalid room check-in or check-out date!', 16, 1)

		PRINT N'All good!'

		COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		THROW;
	END CATCH
END
GO
EXEC [Allocate]
GO
