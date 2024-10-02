SET NOCOUNT ON
GO
UPDATE [Attendees20240919] SET [SharingWith1] = N'Attila Csabrady' WHERE [Ticket_number] = N'2VPS-PF42-W7B1P'
UPDATE [Attendees20240919] SET [SharingWith1] = N'Michelle  Macandrew' WHERE [Ticket_number] = N'2W9P-8DTR-Q7G1P'
UPDATE [Attendees20240919] SET [SharingWith1] = N'Farah Jumat', [Dietary] = N'Gluten Free' WHERE [Ticket_number] = N'2W99-P0Z1-JFL1P'
UPDATE [Attendees20240919] SET [SharingWith1] = N'Kevin Larico Villagomez' WHERE [Ticket_number] = N'2WFP-7F1T-5R51P'
UPDATE [Attendees20240919] SET [SharingWith1] = N'Rachel Curnow' WHERE [Ticket_number] = N'2WF9-TNTJ-37N1P'
UPDATE [Attendees20240919] SET [SharingWith1] = N'Silvia Di Stasio' WHERE [Ticket_number] = N'2WHW-ST08-29N1P'
UPDATE [Attendees20240919] SET [SharingWith1] = N'Chloe Fisher' WHERE [Ticket_number] = N'2WH0-F8J3-MTQ1P'
UPDATE [Attendees20240919] SET [Guest_name] = N'Kally Woodgate', [SharingWith1] = N'Dominic Pisano' WHERE [Ticket_number] = N'2WJ6-Z9NB-81Q1P'
UPDATE [Attendees20240919] SET [Guest_name] = N'Amer Khudari' WHERE [Ticket_number] = N'2WNJ-8T6K-4BC1P'
UPDATE [Attendees20240919] SET [Dietary] = N'Gluten & Dairy Free' WHERE [Ticket_number] = N'2WD3-7JHN-86F1Q'

UPDATE [Attendees20240919] SET [SharingWith1] = N'Irene Salva Lopez' WHERE [Ticket_number] = N'2VPW-TMLV-JPQ1P' --???
UPDATE [Attendees20240919] SET [SharingWith1] = N'Amer Khudari' WHERE [Ticket_number] = N'2WCL-L6KF-GGW1P' --???
UPDATE [Attendees20240919] SET [SharingWith1] = N'Olga Baikova' WHERE [Ticket_number] = N'2WPP-H14W-ZCC1P' --???

GO
INSERT INTO [Attendee] (
	[OrderId],
	[TicketId],
	[TicketType],
	[Forename],
	[Surname],
	[Email],
	[CheckInDay],
	[Dietary]
)
SELECT
	[OrderId] = a.[Order_number],
	[TicketId] = a.[Ticket_number],
	[TicketType] = CASE LEFT(a.[Ticket_type], CHARINDEX(N': ', a.[Ticket_type]) - 1)
			WHEN N'STANDARD ROOM' THEN N'Standard'
			WHEN N'SINGLE ROOM' THEN N'Single'
			WHEN N'PREMIUM SUITE' THEN N'Premium'
		END,
	[Forename] = TRIM(LEFT(a.[Guest_name], s.[Split] - 1)),
	[Surname] = TRIM(RIGHT(a.[Guest_name], LEN(a.[Guest_name]) - s.[Split])),
	[Email] = LOWER(TRIM(a.[Email])),
	[CheckInDay] = CASE
			WHEN a.[Ticket_type] LIKE N'%: Thurs to Mon' THEN 'Thu'
			WHEN a.[Ticket_type] LIKE N'%: Fri to Mon' THEN 'Fri'
		END,
	[Dietary] = CASE a.[Dietary] WHEN N'No' THEN NULL ELSE TRIM(a.[Dietary]) END
FROM [Attendees20240919] a
	CROSS APPLY (VALUES (CHARINDEX(N' ', a.[Guest_Name]))) s ([Split])
GO
UPDATE [Attendee] SET [TicketType] = N'Single', [IsOrganiser] = 1, [IsTeacher] = 1, [IsDJ] = 1 WHERE [FullName] = N'Pierre Henry'
GO
-- ***** SINGLE ROOMS *****
DECLARE @RoomId INT, @OrderId NVARCHAR(100), @TicketId NVARCHAR(max)
DECLARE MyCursor CURSOR FOR
	SELECT [OrderId], [TicketId]
	FROM [Attendee]
	WHERE [TicketType] = N'Single'
OPEN MyCursor
FETCH NEXT FROM MyCursor INTO @OrderId, @TicketId
WHILE @@FETCH_STATUS = 0 BEGIN
	INSERT INTO [Room] ([RoomTypeId], [MaxOccupants])
	SELECT [Id], [MaxOccupants] FROM [RoomType] WHERE [Description] = N'Double Room - Single Occupant'
	SET @RoomId = SCOPE_IDENTITY()
	INSERT INTO [Occupant] ([RoomId], [OccupantId], [MaxOccupants], [OrderId], [TicketId])
	SELECT [Id], 1, [MaxOccupants], @OrderId, @TicketId
	FROM [Room]
	WHERE [Id] = @RoomId
	FETCH NEXT FROM MyCursor INTO @OrderId, @TicketId
END
CLOSE MyCursor
DEALLOCATE MyCursor
GO
-- ***** SAME BOOKING - SHARING *****
DECLARE @RoomId INT, @OrderId NVARCHAR(100), @RoomType NVARCHAR(255)
DECLARE MyCursor CURSOR FOR
	SELECT a.[OrderId], MIN(a.[TicketType])
	FROM [Attendee] a
		LEFT JOIN [Occupant] o ON a.[TicketId] = o.[TicketId]
	WHERE o.[TicketId] IS NULL
	GROUP BY a.[OrderId]
	HAVING COUNT(*) > 1
		AND COUNT(DISTINCT a.[TicketType]) = 1
OPEN MyCursor
FETCH NEXT FROM MyCursor INTO @OrderId, @RoomType
WHILE @@FETCH_STATUS = 0 BEGIN
	INSERT INTO [Room] ([RoomTypeId], [MaxOccupants])
	SELECT [Id], [MaxOccupants]
	FROM [RoomType]
	WHERE [Description] = CASE
			WHEN @OrderId IN (N'2W9B-V5NP-F7W', N'2WL0-M7NZ-S09') THEN N'Double Room'
			WHEN @RoomType = N'Standard' THEN N'Twin Room'
			WHEN @RoomType = N'Premium' THEN N'Jacuzzi Suite'
		END
	SET @RoomId = SCOPE_IDENTITY()
	INSERT INTO [Occupant] ([RoomId], [OccupantId], [MaxOccupants], [OrderId], [TicketId])
	SELECT
		[RoomId] = r.[Id],
		ROW_NUMBER() OVER (ORDER BY a.[TicketId]),
		r.[MaxOccupants],
		a.[OrderId],
		a.[TicketId]
	FROM [Attendee] a, [Room] r
	WHERE a.[OrderId] = @OrderId
		AND r.[Id] = @RoomId
	FETCH NEXT FROM MyCursor INTO @OrderId, @RoomType
END
CLOSE MyCursor
DEALLOCATE MyCursor
GO
-- ***** TWIN ROOMS - NAMED *****
DECLARE @TicketId1 NVARCHAR(100), @TicketId2 NVARCHAR(max), @TicketType NVARCHAR(50), @RoomId INT
DECLARE MyCursor CURSOR FOR
	SELECT [TicketId1] = a1.[Ticket_number], [TicketId2] = a2.[Ticket_number], [TicketType] = LEFT(a1.[Ticket_type], CHARINDEX(N':', a1.[Ticket_type]))
	FROM [Attendees20240919] a1
		JOIN [Attendees20240919] a2 ON LEFT(a1.[Ticket_type], CHARINDEX(N':', a1.[Ticket_type])) = LEFT(a2.[Ticket_type], CHARINDEX(N':', a2.[Ticket_type]))
			AND a2.[SharingWith1] = a1.[Guest_name]
	WHERE a1.[Order_number] != a2.[Order_number]
		AND a1.[Ticket_number] != a2.[Ticket_number]
OPEN MyCursor
FETCH NEXT FROM MyCursor INTO @TicketId1, @TicketId2, @TicketType
WHILE @@FETCH_STATUS = 0 BEGIN
	IF NOT EXISTS (SELECT * FROM [Occupant] WHERE [TicketId] IN (@TicketId1, @TicketId2)) BEGIN
		INSERT INTO [Room] ([RoomTypeId], [MaxOccupants])
		SELECT [Id], [MaxOccupants] FROM [RoomType] WHERE [Description] = CASE
				WHEN @TicketId1 IN (N'2WL0-L6N3-SV71P', N'2WL0-LBDQ-0FK1P', N'2WNR-NWMH-J501P', N'2WNR-P16M-BM61P') THEN N'Double Room'
				WHEN @TicketType = 'PREMIUM SUITE:' THEN 'Jacuzzi Suite'
				ELSE N'Twin Room'
			END
		SET @RoomId = SCOPE_IDENTITY()
		INSERT INTO [Occupant] ([RoomId], [OccupantId], [MaxOccupants], [OrderId], [TicketId])
		SELECT r.[Id], ROW_NUMBER() OVER (ORDER BY a.[TicketId]), r.[MaxOccupants], a.[OrderId], a.[TicketId]
		FROM [Room] r, [Attendee] a
		WHERE r.[Id] = @RoomId
			AND a.[TicketId] IN (@TicketId1, @TicketId2)
	END
	FETCH NEXT FROM MyCursor INTO @TicketId1, @TicketId2, @TicketType
END
CLOSE MyCursor
DEALLOCATE MyCursor
GO
WITH [Temp] AS (
		SELECT o.[RoomId], [Tickets] = COUNT(DISTINCT a.[TicketId])
		FROM [Occupant] o
			JOIN [Attendee] a ON o.[TicketId] = a.[TicketId]
		GROUP BY o.[RoomId]
		HAVING COUNT(DISTINCT a.[FullName]) = 1
			AND COUNT(DISTINCT a.[TicketId]) > 1
	)
UPDATE r
SET [Notes] = N'Single occupant, paid for ' + CONVERT(VARCHAR(10), tmp.[Tickets]) + ' tickets'
FROM [Temp] tmp
	JOIN [Room] r ON tmp.[RoomId] = r.[Id]
GO



--???
DECLARE @RoomId INT
INSERT INTO [Room] ([RoomTypeId], [MaxOccupants])
SELECT [Id], [MaxOccupants] FROM [RoomType] WHERE [Description] = N'Twin Room'
SET @RoomId = SCOPE_IDENTITY()
INSERT INTO [Occupant] ([RoomId], [OccupantId], [MaxOccupants], [OrderId], [TicketId])
SELECT [Id], 1, [MaxOccupants], N'2WC9-TBLZ-D22', N'2WC9-TBLZ-D221P'
FROM [Room]
WHERE [Id] = @RoomId
INSERT INTO [Room] ([RoomTypeId], [MaxOccupants])
SELECT [Id], [MaxOccupants] FROM [RoomType] WHERE [Description] = N'Jacuzzi Suite'
SET @RoomId = SCOPE_IDENTITY()
INSERT INTO [Occupant] ([RoomId], [OccupantId], [MaxOccupants], [OrderId], [TicketId])
SELECT [Id], 1, [MaxOccupants], N'2WDQ-Z3HL-SXF', N'2WDQ-Z3HL-SXF1P'
FROM [Room]
WHERE [Id] = @RoomId