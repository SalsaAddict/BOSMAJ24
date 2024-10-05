USE [Advent_PAH]
GO
SET NOCOUNT ON
GO
DROP PROCEDURE IF EXISTS [Allocate]
GO
CREATE PROCEDURE [Allocate]
AS
BEGIN
	SET NOCOUNT ON

	IF EXISTS (SELECT * FROM [WebSales] WHERE [Ticket_number] = N'2WQD-JT1M-34G1P')
		AND NOT EXISTS (SELECT * FROM [Guest] WHERE [FullName] = N'Lola Gill') BEGIN
		INSERT INTO [Guest] ([Forename], [Surname], [CheckInDate], [CheckOutDate], [Staff])
		VALUES (N'Lola', N'Gill', N'2024-10-31', N'2024-11-04', 0)
	END

	DELETE [Room]
	DBCC CHECKIDENT ([Room], reseed, 1)
	DBCC CHECKIDENT ([Room], reseed)

	INSERT INTO [Room] (
		[RoomTypeId],
		[RoomConfigId],
		[GuestId1],
		[GuestId2],
		[Random]
	)
	-- ***** ARTISTS *****
	SELECT
		[RoomTypeId] = a.[RoomTypeId], 
		[RoomConfigId] = a.[RoomConfigId],
		[GuestId1] = g1.[Id],
		[GuestId2] = g2.[Id],
		[Random] = CONVERT(BIT, 0)
	FROM [Artist] a
		LEFT JOIN [Guest] g1 ON a.[Forename1] + ISNULL(N' ' + a.[Surname1], N'') = g1.[FullName]
		LEFT JOIN [Guest] g2 ON a.[Forename2] + ISNULL(N' ' + a.[Surname2], N'') = g2.[FullName]
	-- ***** SINGLE ROOMS *****
	UNION ALL
	SELECT
		[RoomTypeId] = N'U',
		[RoomConfigId] = N'D',
		[GuestId1] = g.[Id],
		[GuestId2] = NULL,
		[Random] = CONVERT(BIT, 0)
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
		[Random] = CONVERT(BIT, 0)
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
		[Random] = CONVERT(BIT, 0)
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
	-- ***** MANUAL MATCHES *****
	UNION ALL
	SELECT
		[RoomTypeId] = rt.[Id],
		[RoomConfigId] = rc.[Id],
		[GuestId1] = g1.[Id],
		[GuestId2] = g2.[Id],
		[Random] = CONVERT(BIT, 1)
	FROM (VALUES
				(N'2VPS-PF42-W7B1P', N'2VPP-J3GQ-7501P', N'J', N'T'),
				(N'2WM4-TG2D-BKT1P', N'2W99-P0Z1-JFL1P', N'S', N'T'),
				(N'2WP9-3ZDF-LVP1P', N'2WQG-LGCV-NBL1P', N'S', N'T'),
				(N'2WF9-TNTJ-37N1P', N'2WMC-PXRG-S0M1P', N'S', N'T'),
				(N'2WK7-B34X-N8H1P', N'2WFP-7F1T-5R51P', N'S', N'T'),
				(N'2WQH-2D36-PF31P', N'2WFD-SNFT-0WH1P', N'S', N'T'),
				(N'2WHW-ST08-29N1P', N'2WHC-JQ9P-SZW1P', N'S', N'T'),
				(N'2WQC-0F28-HXJ1P', N'2WH0-F8J3-MTQ1P', N'S', N'T'),
				(N'2WNJ-8T6K-4BC1P', N'2WQB-B4QB-WSR1P', N'S', N'T'),
				(N'2WR9-ZVB2-2RL1P', N'2WC9-TBLZ-D221P', N'S', N'T'),
			
				(N'2WDQ-Z3HL-SXF1P', NULL, N'J', N'T'),
				(N'2VPW-TMLV-JPQ1P', NULL, N'S', N'T'),
				(N'2WQW-TD19-KKQ1P', NULL, N'S', N'T'),
				(N'2WQQ-Q3QC-4J01P', NULL, N'J', N'T'),
				(N'2WRX-DH75-35F1P', NULL, N'S', N'T') -- Waiting for Nived Subbarayan
			) shr ([TicketId1], [TicketId2], [RoomTypeId], [RoomConfigId])
		JOIN [RoomType] rt ON shr.[RoomTypeId] = rt.[Id]
		JOIN [RoomConfig] rc ON shr.[RoomConfigId] = rc.[Id]
		JOIN [Guest] g1 ON shr.[TicketId1] = g1.[TicketId]
		LEFT JOIN [Guest] g2 ON shr.[TicketId2] = g2.[TicketId]
	-- ***** Kevin & Lola Gill
	UNION ALL
	SELECT
		[RoomTypeId] = N'S',
		[RoomConfigId] = N'T',
		[GuestId1] = g1.[Id],
		[GuestId2] = g2.[Id],
		[Random] = CONVERT(BIT, 0)
	FROM [Guest] g1, [Guest] g2
	WHERE g1.[TicketId] = N'2WQD-JT1M-34G1P'
		AND g2.[TicketId] IS NULL AND g2.[FullName] = N'Lola Gill'

	UPDATE r
	SET
		[GuestId2] = g2.[Id],
		[Random] = CONVERT(BIT, 0)
	FROM (VALUES
				(N'Sirran Elves', N'2W8T-748N-45B1P'),
				(N'Thalia Padilla', N'2WQH-313N-D7W1P'),
				(N'Lola Gill', N'2WQD-JT1M-34G1P'),
				(N'Debora Lima', N'2WQQ-V5B3-CNS1P')
			) shr ([ArtistFullName], [TicketId])
		JOIN [Guest] g1 ON g1.[Staff] = 1 AND shr.[ArtistFullName] = g1.[FullName]
		JOIN [Guest] g2 ON shr.[TicketId] = g2.[TicketId]
		JOIN [Room] r ON g1.[Id] = r.[GuestId1]

	RETURN
END
GO
EXEC [Allocate]
GO
