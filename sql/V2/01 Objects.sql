SET NOCOUNT ON
GO
DROP PROCEDURE IF EXISTS [ExportTeachers]
DROP PROCEDURE IF EXISTS [ExportTimetable]
DROP VIEW IF EXISTS [WorkshopsPerTeacher]
DROP TABLE IF EXISTS [Workshop]
DROP TABLE IF EXISTS [Genre]
DROP TABLE IF EXISTS [Level]
DROP TABLE IF EXISTS [Slot]
DROP TABLE IF EXISTS [Area]
GO
DROP PROCEDURE IF EXISTS [ExportGuestInfo]
DROP PROCEDURE IF EXISTS [Allocate]
DROP VIEW IF EXISTS [GuestInfo]
DROP VIEW IF EXISTS [RoomCount]
DROP PROCEDURE IF EXISTS [Import]
DROP VIEW IF EXISTS [Acts]
DROP TABLE IF EXISTS [Act]
DROP VIEW IF EXISTS [Rooms]
DROP VIEW IF EXISTS [OneRoomPerGuest]
DROP TABLE IF EXISTS [Room]
DROP TABLE IF EXISTS [Match]
DROP TABLE IF EXISTS [Staging]
DROP TABLE IF EXISTS [RoomTypeConfig]
DROP TABLE IF EXISTS [RoomConfig]
DROP TABLE IF EXISTS [RoomType]
DROP TABLE IF EXISTS [Guest]
DROP TABLE IF EXISTS [GuestType]
DROP TABLE IF EXISTS [Diet]
DROP TABLE IF EXISTS [Stay]
DROP TABLE IF EXISTS [Day]
DROP VIEW IF EXISTS [WebSalesOrderSequence]
DROP VIEW IF EXISTS [WebSalesTicketsPerOrder]
DROP TABLE IF EXISTS [WebSales]
GO
CREATE TABLE [WebSales] (
	[Order_number] NVARCHAR(50) NOT NULL,
	[Order_date] SMALLDATETIME NOT NULL,
	[Guest_first_name] NVARCHAR(127) NOT NULL,
	[Guest_last_name] NVARCHAR(127) NOT NULL,
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
	CONSTRAINT [UQ_WebSales_Guest_full_name] UNIQUE ([Ticket_number], [Guest_first_name], [Guest_last_name]),
	CONSTRAINT [CK_WebSales_Someone_to_share_with] CHECK ([Someone_to_share_with] IN (N'yes', N'no'))
)
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
CREATE TABLE [Stay] (
	[CheckInDate] DATE NOT NULL,
	[CheckOutDate] DATE NOT NULL,
	[Description] AS LEFT(DATENAME(weekday, [CheckInDate]), 3) + N'-' + LEFT(DATENAME(weekday, [CheckOutDate]), 3),
	[Nights] AS DATEDIFF(day, [CheckInDate], [CheckOutDate]),
	[AllowReservation] BIT NOT NULL,
	CONSTRAINT [PK_Period] PRIMARY KEY CLUSTERED ([CheckInDate], [CheckOutDate]),
	CONSTRAINT [CK_Period_CheckOutDate] CHECK ([CheckOutDate] >= [CheckInDate])
)
GO
INSERT INTO [Stay] ([CheckInDate], [CheckOutDate], [AllowReservation])
VALUES
	(N'2024-10-31', N'2024-11-04', 1),
	(N'2024-11-01', N'2024-11-04', 1),
	(N'2024-10-31', N'2024-11-03', 0),
	(N'2024-11-02', N'2024-11-04', 0),
	(N'2024-11-01', N'2024-11-03', 0)
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
	[FlightInTime] TIME NULL,
	[ArriveWhen] AS DATEADD(minute, DATEDIFF(minute, 0, ISNULL(DATEADD(hour, 4, [FlightInTime]), N'15:00')), CONVERT(SMALLDATETIME, [CheckInDate])),
	[CheckOutDate] DATE NOT NULL,
	[FlightOutTime] TIME NULL,
	[DepartWhen] AS DATEADD(minute, DATEDIFF(minute, 0, ISNULL(DATEADD(hour, -4, [FlightOutTime]), N'10:00')), CONVERT(SMALLDATETIME, [CheckOutDate])),
	[DietaryInfo] NVARCHAR(255) NULL,
	[Staff] BIT NOT NULL,
	CONSTRAINT [PK_Guest] PRIMARY KEY CLUSTERED ([Id]),
	CONSTRAINT [UQ_Guest_FullName] UNIQUE ([FullName]),
	CONSTRAINT [UQ_Guest_Act] UNIQUE ([FullName], [Staff]),
	CONSTRAINT [FK_Guest_WebSales] FOREIGN KEY ([TicketId], [Forename], [Surname]) REFERENCES [WebSales] ([Ticket_number], [Guest_first_name], [Guest_last_name]),
	CONSTRAINT [FK_Guest_Stay] FOREIGN KEY ([CheckInDate], [CheckOutDate]) REFERENCES [Stay] ([CheckInDate], [CheckOutDate]),
	CONSTRAINT [FK_Guest_Diet] FOREIGN KEY ([DietaryInfo]) REFERENCES [Diet] ([DietaryInfo]),
	CONSTRAINT [FK_Guest_GuestType] FOREIGN KEY ([Staff]) REFERENCES [GuestType] ([Staff])
)
GO
CREATE UNIQUE INDEX [IX_Guest_TicketId] ON [Guest] ([TicketId]) WHERE [TicketId] IS NOT NULL
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
CREATE TABLE [Staging] (
	[Forename] NVARCHAR(127) NOT NULL,
	[Surname] NVARCHAR(127) NULL,
	[DietaryInfo] NVARCHAR(255) NULL,
	[CheckInDate] DATE NOT NULL,
	[FlightInTime] TIME NULL,
	[CheckOutDate] DATE NOT NULL,
	[FlightOutTime] TIME NULL,
	[Staff] BIT NOT NULL
)
GO
CREATE TABLE [Match] (
	[Guest1] NVARCHAR(255) NOT NULL,
	[Guest2] NVARCHAR(255) NULL,
	[RoomTypeId] NCHAR(1) NOT NULL,
	[RoomConfigId] NCHAR(1) NOT NULL,
	[Confirmed] BIT NOT NULL,
	CONSTRAINT [FK_Match_Guest_1] FOREIGN KEY ([Guest1]) REFERENCES [Guest] ([FullName]),
	CONSTRAINT [FK_Match_Guest_2] FOREIGN KEY ([Guest2]) REFERENCES [Guest] ([FullName]),
	CONSTRAINT [FK_Match_RoomType] FOREIGN KEY ([RoomTypeId]) REFERENCES [RoomType] ([Id]),
	CONSTRAINT [FK_Match_RoomConfig] FOREIGN KEY ([RoomConfigId]) REFERENCES [RoomConfig] ([Id])
)
GO
CREATE TABLE [Room] (
	[Id] INT NOT NULL IDENTITY (1, 1),
	[RoomTypeId] NCHAR(1) NOT NULL,
	[RoomConfigId] NCHAR(1) NOT NULL,
	[GuestId1] INT NOT NULL,
	[GuestId2] INT NULL,
	[Confirmed] BIT,
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
	[CheckInDate] = CONVERT(DATE, CASE WHEN MIN(g.[CheckInDate]) > N'2024-11-01' THEN N'2024-11-01' ELSE MIN(g.[CheckInDate]) END),
	[CheckOutDate] = CONVERT(DATE, N'2024-11-04'),
	[Occupants] = COUNT_BIG(*),
	[GuestId1] = MIN(r.[GuestId1]),
	[GuestId2] = MIN(r.[GuestId2]),
	[Confirmed] = r.[Confirmed]
FROM [dbo].[Guest] g
	JOIN [dbo].[Room] r ON g.[Id] IN (r.[GuestId1], r.[GuestId2])
GROUP BY r.[Id], r.[RoomTypeId], r.[RoomConfigId], r.[Confirmed]
GO
CREATE TABLE [Act] (
	[Name] NVARCHAR(255) NOT NULL,
	[Artist1] NVARCHAR(255) NOT NULL,
	[Artist2] NVARCHAR(255) NULL,
	[Staff] BIT NOT NULL,
	CONSTRAINT [PK_Act] PRIMARY KEY ([Name]),
	CONSTRAINT [CK_Act_Staff] CHECK ([Staff] = 1),
	CONSTRAINT [FK_Act_Guest_Artist1] FOREIGN KEY ([Artist1], [Staff])
		REFERENCES [Guest] ([FullName], [Staff]),
	CONSTRAINT [FK_Act_Guest_Artist2] FOREIGN KEY ([Artist2], [Staff])
		REFERENCES [Guest] ([FullName], [Staff])
)
GO
CREATE VIEW [Acts]
WITH SCHEMABINDING
AS
SELECT
	[Name] = a.[Name],
	[ArriveWhen] = MAX(g.[ArriveWhen]),
	[DepartWhen] = MIN(g.[DepartWhen])
FROM [dbo].[Act] a
	JOIN [dbo].[Guest] g ON g.[FullName] IN (a.[Artist1], a.[Artist2])
GROUP BY a.[Name]
GO
CREATE PROCEDURE [Import]
AS
BEGIN
	SET NOCOUNT ON

	DELETE [Workshop]
	DELETE [Act]
	DELETE [Room]
	DBCC CHECKIDENT ([Room], reseed, 1)
	DBCC CHECKIDENT ([Room], reseed)
	DELETE [Match]
	DELETE [Guest]
	DBCC CHECKIDENT ([Guest], reseed, 1)
	DBCC CHECKIDENT ([Guest], reseed)
	DELETE [Staging]
	DELETE [WebSales]

	BULK INSERT [dbo].[WebSales]
	FROM 'D:\tmp\websales.csv'
	WITH (
			DATAFILETYPE = 'widechar',
			FORMAT = 'CSV',
			FIRSTROW = 2,
			CHECK_CONSTRAINTS
		)

	BULK INSERT [dbo].[Staging]
	FROM 'D:\tmp\staging.csv'
	WITH (
			DATAFILETYPE = 'widechar',
			FORMAT = 'CSV',
			FIRSTROW = 2,
			CHECK_CONSTRAINTS
		)

	-- Dominic Pisano & Kally Woodgate
	UPDATE [WebSales]
	SET [Guest_first_name] = N'Kally', [Guest_last_name] = N'Woodgate', [Sharing_info_1] = N'Dominic Pisano'
	WHERE [Ticket_number] = N'2WJ6-Z9NB-81Q1P'

	-- Deferred until next year
	DELETE [WebSales] WHERE [Ticket_number] IN (N'2WF5-0QSG-CZX1P', N'2WF9-FXXG-7V81P')

	INSERT INTO [Guest] ([TicketId], [Forename], [Surname], [CheckInDate], [CheckOutDate], [DietaryInfo], [Staff])
	SELECT
		s.[Ticket_number],
		[Forename] = s.[Guest_first_name],
		[Surname] = s.[Guest_last_name],
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
		[Staff] = CONVERT(BIT, 0)
	FROM [WebSales] s
		OUTER APPLY (VALUES (NULLIF(TRIM(s.[Dietary_info]), N'No'))) td ([DietaryInfo])
		LEFT JOIN [Diet] d ON td.[DietaryInfo] = d.[DietaryInfo]

	MERGE
	INTO [Guest] t
	USING [Staging] s
	ON t.[FullName] = s.[Forename] + ISNULL(N' ' + s.[Surname], N'')
	WHEN MATCHED THEN UPDATE SET
		[CheckInDate] = s.[CheckInDate],
		[FlightInTime] = s.[FlightInTime],
		[CheckOutDate] = s.[CheckOutDate],
		[FlightOutTime] = s.[FlightOutTime],
		[Staff] = s.[Staff]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([Forename], [Surname], [CheckInDate], [FlightInTime], [CheckOutDate], [FlightOutTime], [Staff])
		VALUES (s.[Forename], s.[Surname], s.[CheckInDate], s.[FlightInTime], s.[CheckOutDate], s.[FlightOutTime], s.[Staff]);

	BULK INSERT [dbo].[Match]
	FROM 'D:\tmp\match.csv'
	WITH (
			DATAFILETYPE = 'widechar',
			FORMAT = 'CSV',
			FIRSTROW = 2,
			CHECK_CONSTRAINTS
		)

	BULK INSERT [dbo].[Act]
	FROM 'D:\tmp\act.csv'
	WITH (
			DATAFILETYPE = 'widechar',
			FORMAT = 'CSV',
			FIRSTROW = 2,
			CHECK_CONSTRAINTS
		)

	BULK INSERT [dbo].[Workshop]
	FROM 'D:\tmp\workshop.csv'
	WITH (
			DATAFILETYPE = 'widechar',
			FORMAT = 'CSV',
			FIRSTROW = 2,
			CHECK_CONSTRAINTS
		)

	RETURN
END
GO
