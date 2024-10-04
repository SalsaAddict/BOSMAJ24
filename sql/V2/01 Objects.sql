USE [Advent_PAH]
GO
SET NOCOUNT ON
GO
DROP PROCEDURE IF EXISTS [ExportGuestInfo]
DROP VIEW IF EXISTS [GuestInfo]
DROP VIEW IF EXISTS [RoomCount]
DROP VIEW IF EXISTS [Finance]
DROP PROCEDURE IF EXISTS [ImportWebSales]
DROP VIEW IF EXISTS [Rooms]
DROP VIEW IF EXISTS [OneRoomPerGuest]
DROP TABLE IF EXISTS [Room]
DROP TABLE IF EXISTS [RoomTypeConfig]
DROP TABLE IF EXISTS [RoomConfig]
DROP TABLE IF EXISTS [RoomType]
DROP TABLE IF EXISTS [Guest]
DROP TABLE IF EXISTS [GuestType]
DROP TABLE IF EXISTS [Diet]
DROP TABLE IF EXISTS [Stay]
DROP TABLE IF EXISTS [Artist]
DROP VIEW IF EXISTS [WebSalesOrderSequence]
DROP VIEW IF EXISTS [WebSalesTicketsPerOrder]
DROP VIEW IF EXISTS [WebSalesNames]
DROP TABLE IF EXISTS [WebSales]
GO
CREATE TABLE [WebSales] (
	[Order_number] NVARCHAR(50) NOT NULL,
	[Order_date] SMALLDATETIME NOT NULL,
	[Guest_name] NVARCHAR(255) NOT NULL,
	[Email] NVARCHAR(50) NOT NULL,
	[Ticket_type] NVARCHAR(50) NOT NULL,
	[Ticket_number] NVARCHAR(50) NOT NULL,
	[Ticket_price] MONEY NOT NULL,
	[Benefit] NVARCHAR(1) NULL,
	[Coupon] NVARCHAR(50) NULL,
	[Tax] MONEY NOT NULL,
	[Total_ticket_price] MONEY NOT NULL,
	[Wix_service_fee] MONEY NOT NULL,
	[Ticket_revenue] MONEY NOT NULL,
	[Payment_status] NVARCHAR(50) NOT NULL,
	[Checked_in] NVARCHAR(50) NOT NULL,
	[Seat_Information] NVARCHAR(1) NULL,
	[Someone_to_share_with] NVARCHAR(25) NULL,
	[Sharing_info_1] NVARCHAR(200) NULL,
	[Sharing_info_2] NVARCHAR(200) NULL,
	[Dietary_info] NVARCHAR(50) NULL,
	CONSTRAINT [PK_WebSales] PRIMARY KEY CLUSTERED ([Ticket_number]),
	CONSTRAINT [UQ_WebSales_Guest_name] UNIQUE ([Ticket_number], [Guest_name]),
	CONSTRAINT [CK_WebSales_Someone_to_share_with] CHECK ([Someone_to_share_with] IN (N'yes', N'no'))
)
GO
CREATE VIEW [WebSalesNames]
WITH SCHEMABINDING
AS
SELECT
	[Ticket_number],
	[Guest_name],
	[Guest_forename] = TRIM(LEFT([Guest_name], CHARINDEX(N' ', [Guest_name]) - 1)),
	[Guest_surname] = TRIM(RIGHT([Guest_name], LEN([Guest_name]) - CHARINDEX(N' ', [Guest_name])))
FROM [dbo].[WebSales]
GO
CREATE UNIQUE CLUSTERED INDEX [PK_WebSalesNames] ON [WebSalesNames] ([Ticket_number])
GO
CREATE VIEW [WebSalesTicketsPerOrder]
WITH SCHEMABINDING
AS
SELECT
	[Ticket_type],
	[Order_number],
	[Ticket_count] = COUNT_BIG(*)
FROM [dbo].[WebSales]
GROUP BY [Order_number], [Ticket_type]
GO
CREATE UNIQUE CLUSTERED INDEX [IX_WebSalesTicketsPerOrder] ON [WebSalesTicketsPerOrder] ([Order_number], [Ticket_type])
GO
CREATE VIEW [WebSalesOrderSequence]
WITH SCHEMABINDING
AS
SELECT
	[Ticket_type],
	[Order_number],
	[Order_sequence] = ROW_NUMBER() OVER (
			PARTITION BY [Ticket_type], [Order_number]
			ORDER BY [Ticket_number]
		),
	[Ticket_number]
FROM [dbo].[WebSales]
GO
CREATE TABLE [Artist] (
	[Forename1] NVARCHAR(127) NOT NULL,
	[Surname1] NVARCHAR(127) NULL,
	[Forename2] NVARCHAR(127) NULL,
	[Surname2] NVARCHAR(127) NULL,
	[RoomTypeId] NCHAR(1) NOT NULL,
	[RoomConfigId] NCHAR(1) NOT NULL
)
GO
CREATE TABLE [Stay] (
	[CheckInDate] DATE NOT NULL,
	[CheckOutDate] DATE NOT NULL,
	[Description] AS LEFT(DATENAME(weekday, [CheckInDate]), 3) + N'-' + LEFT(DATENAME(weekday, [CheckOutDate]), 3),
	[Nights] AS DATEDIFF(day, [CheckInDate], [CheckOutDate]),
	CONSTRAINT [PK_Period] PRIMARY KEY CLUSTERED ([CheckInDate], [CheckOutDate]),
	CONSTRAINT [CK_Period_CheckOutDate] CHECK ([CheckOutDate] >= [CheckInDate])
)
GO
INSERT INTO [Stay] ([CheckInDate], [CheckOutDate])
VALUES
	(N'2024-10-31', N'2024-11-04'),
	(N'2024-11-01', N'2024-11-04')
GO
CREATE TABLE [Diet] (
	[DietaryInfo] NVARCHAR(255) NOT NULL,
	CONSTRAINT [PK_Diet] PRIMARY KEY CLUSTERED ([DietaryInfo])
)
GO
INSERT INTO [Diet]
VALUES
	(N'Vegan'),
	(N'Vegetarian'),
	(N'Gluten Free'),
	(N'Gluten & Dairy Free')
GO
CREATE TABLE [GuestType] (
	[Staff] BIT NOT NULL,
	[Description] NVARCHAR(255) NOT NULL,
	CONSTRAINT [PK_GuestType] PRIMARY KEY CLUSTERED ([Staff]),
	CONSTRAINT [UQ_GuestType_Description] UNIQUE ([Description])
)
GO
INSERT INTO [GuestType] ([Staff], [Description])
VALUES
	(0, N'Event Guests'),
	(1, N'Event Staff & Artists')
GO
CREATE TABLE [Guest] (
	[Id] INT NOT NULL IDENTITY (1, 1),
	[TicketId] NVARCHAR(50) NULL,
	[Forename] NVARCHAR(127) NOT NULL,
	[Surname] NVARCHAR(127) NULL,
	[FullName] AS CONVERT(NVARCHAR(255), [Forename] + ISNULL(N' ' + [Surname], N'')) PERSISTED,
	[CheckInDate] DATE NOT NULL,
	[CheckOutDate] DATE NOT NULL,
	[DietaryInfo] NVARCHAR(255) NULL,
	[Staff] BIT NOT NULL,
	CONSTRAINT [PK_Guest] PRIMARY KEY CLUSTERED ([Id]),
	CONSTRAINT [FK_Guest_WebSales] FOREIGN KEY ([TicketId], [FullName]) REFERENCES [WebSales] ([Ticket_number], [Guest_name]),
	CONSTRAINT [FK_Guest_Stay] FOREIGN KEY ([CheckInDate], [CheckOutDate]) REFERENCES [Stay] ([CheckInDate], [CheckOutDate]),
	CONSTRAINT [FK_Guest_Diet] FOREIGN KEY ([DietaryInfo]) REFERENCES [Diet] ([DietaryInfo]),
	CONSTRAINT [FK_Guest_GuestType] FOREIGN KEY ([Staff]) REFERENCES [GuestType] ([Staff])
)
GO
CREATE UNIQUE INDEX [IX_Guest_TicketId] ON [Guest] ([TicketId]) WHERE [TicketId] IS NOT NULL
GO
CREATE UNIQUE INDEX [IX_Guest_FullName] ON [Guest] ([FullName]) WHERE [Staff] = 1
GO
CREATE TABLE [RoomType] (
	[Id] NCHAR(1) NOT NULL,
	[Description] NVARCHAR(255) NOT NULL,
	[PricePerPersonPerNight] MONEY NOT NULL,
	[MinPeople] TINYINT NOT NULL,
	[Sort] TINYINT NOT NULL,
	CONSTRAINT [PK_RoomType] PRIMARY KEY CLUSTERED ([Id]),
	CONSTRAINT [UQ_RoomType_Description] UNIQUE ([Description]),
	CONSTRAINT [UQ_RoomType_Sort] UNIQUE ([Sort]),
	CONSTRAINT [CK_RoomType_MinPeople] CHECK ([MinPeople] BETWEEN 1 AND 2)
)
GO
INSERT INTO [RoomType] ([Id], [Description], [PricePerPersonPerNight], [MinPeople], [Sort])
VALUES
	(N'U', N'Single Room', 126, 1, 1),
	(N'S', N'Standard Room', 84, 2, 2),
	(N'J', N'Premium Suite with Jacuzzi', 109, 2, 3)
GO
CREATE TABLE [RoomConfig] (
	[Id] NCHAR(1) NOT NULL,
	[Description] NVARCHAR(255) NOT NULL,
	[Sort] TINYINT NOT NULL,
	CONSTRAINT [PK_RoomConfig] PRIMARY KEY CLUSTERED ([Id]),
	CONSTRAINT [UQ_RoomConfig_Description] UNIQUE ([Description]),
	CONSTRAINT [UQ_RoomConfig_Sort] UNIQUE ([Sort])
)
GO
INSERT INTO [RoomConfig] ([Id], [Description], [Sort])
VALUES
	(N'D', N'1 Double Bed', 1),
	(N'T', N'2 Single Beds', 2)
GO
CREATE TABLE [RoomTypeConfig] (
	[RoomTypeId] NCHAR(1) NOT NULL,
	[RoomConfigId] NCHAR(1) NOT NULL,
	CONSTRAINT [PK_RoomTypeConfig] PRIMARY KEY CLUSTERED ([RoomTypeId], [RoomConfigId]),
	CONSTRAINT [FK_RoomTypeConfig_RoomType] FOREIGN KEY ([RoomTypeId]) REFERENCES [RoomType] ([Id]),
	CONSTRAINT [FK_RoomTypeConfig_RoomConfig] FOREIGN KEY ([RoomConfigId]) REFERENCES [RoomConfig] ([Id])
)
GO
INSERT INTO [RoomTypeConfig] ([RoomTypeId], [RoomConfigId])
VALUES
	(N'U', N'D'),
	(N'S', N'D'),
	(N'S', N'T'),
	(N'J', N'D'),
	(N'J', N'T')
GO
CREATE TABLE [Room] (
	[Id] INT NOT NULL IDENTITY (1, 1),
	[RoomTypeId] NCHAR(1) NOT NULL,
	[RoomConfigId] NCHAR(1) NOT NULL,
	[GuestId1] INT NOT NULL,
	[GuestId2] INT NULL,
	CONSTRAINT [PK_Room] PRIMARY KEY CLUSTERED ([Id]),
	CONSTRAINT [FK_Room_RoomTypeConfig] FOREIGN KEY ([RoomTypeId], [RoomConfigId]) REFERENCES [RoomTypeConfig] ([RoomTypeId], [RoomConfigId]),
	CONSTRAINT [FK_Room_Guest1] FOREIGN KEY ([GuestId1]) REFERENCES [Guest] ([Id]),
	CONSTRAINT [FK_Room_Guest2] FOREIGN KEY ([GuestId2]) REFERENCES [Guest] ([Id]),
)
GO
CREATE VIEW [OneRoomPerGuest]
WITH SCHEMABINDING
AS
SELECT g.[Id], g.[FullName]
FROM [dbo].[Guest] g
	JOIN [dbo].[Room] r ON g.[Id] IN (r.[GuestId1], r.[GuestId2])
GO
CREATE UNIQUE CLUSTERED INDEX [PK_OneRoomPerGuest] ON [OneRoomPerGuest] ([Id])
GO
CREATE VIEW [Rooms]
WITH SCHEMABINDING
AS
SELECT
	[RoomId] = r.[Id],
	[Staff] = CONVERT(BIT, CASE WHEN MAX(CONVERT(INT, g.[Staff])) = 1 THEN 1 ELSE 0 END),
	[RoomTypeId] = r.[RoomTypeId],
	[RoomConfigId] = r.[RoomConfigId],
	[CheckInDate] = MIN(g.[CheckInDate]),
	[CheckOutDate] = MAX(g.[CheckOutDate]),
	[Occupants] = COUNT_BIG(*),
	[GuestId1] = MIN(r.[GuestId1]),
	[GuestId2] = MIN(r.[GuestId2])
FROM [dbo].[Guest] g
	JOIN [dbo].[Room] r ON g.[Id] IN (r.[GuestId1], r.[GuestId2])
GROUP BY r.[Id], r.[RoomTypeId], r.[RoomConfigId]
GO
CREATE PROCEDURE [ImportWebSales]
AS
BEGIN
	SET NOCOUNT ON

	DELETE [WebSales]

	BULK INSERT [dbo].[Artist]
	FROM 'D:\tmp\artists.csv'
	WITH (
			DATAFILETYPE = 'widechar',
			FORMAT = 'CSV',
			FIRSTROW = 2
		)

	BULK INSERT [dbo].[WebSales]
	FROM 'D:\tmp\websales.csv'
	WITH (
			DATAFILETYPE = 'widechar',
			FORMAT = 'CSV',
			FIRSTROW = 2
		)

	UPDATE s
	SET [Guest_name] = n.[Guest_forename] + N' ' + n.[Guest_surname]
	FROM [WebSales] s
		JOIN [WebSalesNames] n ON s.[Ticket_number] = n.[Ticket_number]

	-- Pierre Henry
	UPDATE [WebSales]
	SET [Ticket_type] = N'SINGLE ROOM: Thurs to Mon'
	WHERE [Ticket_number] = N'2WK6-SXTG-FVC1P'

	-- Dominic Pisano & Kally Woodgate
	UPDATE [WebSales]
	SET [Guest_name] = N'Kally Woodgate', [Sharing_info_1] = N'Dominic Pisano'
	WHERE [Ticket_number] = N'2WJ6-Z9NB-81Q1P'

	INSERT INTO [Guest] ([Forename], [Surname], [CheckInDate], [CheckOutDate], [Staff])
	SELECT [Forename1], [Surname1], N'2024-10-31', N'2024-11-04', 1
	FROM [Artist]
	UNION ALL
	SELECT [Forename2], [Surname2], N'2024-10-31', N'2024-11-04', 1
	FROM [Artist]
	WHERE [Forename2] IS NOT NULL
	ORDER BY 1, 2

	INSERT INTO [Guest] ([TicketId], [Forename], [Surname], [CheckInDate], [CheckOutDate], [DietaryInfo], [Staff])
	SELECT
		s.[Ticket_number],
		n.[Guest_forename],
		n.[Guest_surname],
		[CheckInDate] = CASE RIGHT(s.[Ticket_type], LEN(s.[Ticket_type]) - CHARINDEX(N': ', s.[Ticket_type]) - 1)
				WHEN N'Thurs to Mon' THEN N'2024-10-31'
				WHEN N'Fri to Mon' THEN N'2024-11-01'
			END,
		[CheckOutDate] = N'2024-11-04',
		[DietaryInfo] = CASE
				WHEN s.[Ticket_number] = N'2W99-P0Z1-JFL1P' THEN N'Gluten Free' -- See [Sharing_info_2]
				WHEN s.[Ticket_number] = N'2WD3-7JHN-86F1Q' THEN N'Gluten & Dairy Free' -- See [Sharing_info_2]
				ELSE ISNULL(d.[DietaryInfo], td.[DietaryInfo])
			END,
		[Staff] = CASE
				WHEN s.[Guest_name] = N'Pierre Henry' AND s.[Ticket_number] = N'2WK6-SXTG-FVC1P' THEN 1
				WHEN s.[Guest_name] = N'Qiosen Feng' AND s.[Ticket_number] = N'2WK6-QWBS-4J31Q' THEN 1
				ELSE 0
			END
	FROM [WebSales] s
		JOIN [WebSalesNames] n ON s.[Ticket_number] = n.[Ticket_number]
		OUTER APPLY (VALUES (NULLIF(TRIM(s.[Dietary_info]), N'No'))) td ([DietaryInfo])
		LEFT JOIN [Diet] d ON td.[DietaryInfo] = d.[DietaryInfo]

	RETURN
END
GO
CREATE VIEW [Finance]
WITH SCHEMABINDING
AS
SELECT TOP 100 PERCENT
	[Category] = gt.[Description],
	[Type] = rt.[Description],
	[Configuration] = rc.[Description],
	[Stay] = per.[Description],
	[Total Rooms] = COUNT(DISTINCT r.[RoomId]),
	[Total Guests] = COUNT(DISTINCT g.[Id]),
	[Web Sales Revenue] = SUM(ISNULL(s.[Ticket_revenue], 0))
	--[Profit] = SUM(ISNULL(s.[Ticket_revenue], 0)) - (rt.[PricePerPersonPerNight] * rt.[MinPeople] * per.[Nights] * COUNT(DISTINCT r.[RoomId]))
FROM [dbo].[Rooms] r
	JOIN [dbo].[GuestType] gt ON r.[Staff] = gt.[Staff]
	JOIN [dbo].[RoomType] rt ON r.[RoomTypeId] = rt.[Id]
	JOIN [dbo].[RoomConfig] rc ON r.[RoomConfigId] = rc.[Id]
	JOIN [dbo].[Stay] per ON r.[CheckInDate] = per.[CheckInDate] AND r.[CheckOutDate] = per.[CheckOutDate]
	LEFT JOIN [dbo].[Guest] g ON g.[Id] IN (r.[GuestId1], r.[GuestId2])
	LEFT JOIN [dbo].[WebSales] s ON g.[TicketId] = s.[Ticket_number]
GROUP BY
	r.[Staff], gt.[Description],
	rt.[Sort], rt.[Description], rt.[PricePerPersonPerNight], rt.[MinPeople],
	rc.[Sort], rc.[Description],
	per.[Nights], per.[Description]
ORDER BY
	r.[Staff] DESC,
	rt.[Sort], rt.[Description],
	rc.[Sort], rc.[Description],
	per.[Nights] DESC
GO
CREATE VIEW [RoomCount]
WITH SCHEMABINDING
AS
SELECT TOP 100 PERCENT
	[Type] = rt.[Description],
	[Configuration] = rc.[Description],
	[ThuA] = COUNT(CASE WHEN per.[Description] = N'Thu-Mon' AND r.[Staff] = 1 THEN 1 END),
	[ThuG] = COUNT(CASE WHEN per.[Description] = N'Thu-Mon' AND r.[Staff] = 0 THEN 1 END),
	[FriA] = COUNT(CASE WHEN per.[Description] = N'Fri-Mon' AND r.[Staff] = 1 THEN 1 END),
	[FriG] = COUNT(CASE WHEN per.[Description] = N'Fri-Mon' AND r.[Staff] = 0 THEN 1 END),
	[Total] = COUNT(*)
FROM [dbo].[Rooms] r
	JOIN [dbo].[RoomType] rt ON r.[RoomTypeId] = rt.[Id]
	JOIN [dbo].[RoomConfig] rc ON r.[RoomConfigId] = rc.[Id]
	JOIN [dbo].[Stay] per ON r.[CheckInDate] = per.[CheckInDate] AND r.[CheckOutDate] = per.[CheckOutDate]
GROUP BY
	rt.[Sort], rt.[Description],
	rc.[Sort], rc.[Description]
ORDER BY
	rt.[Sort], rt.[Description],
	rc.[Sort], rc.[Description]
GO